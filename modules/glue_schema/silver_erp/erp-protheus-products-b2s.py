import sys
from datetime import date, timedelta

import boto3
from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from pyspark.context import SparkContext
from pyspark.sql import functions as F


args = getResolvedOptions(sys.argv, [
    "JOB_NAME",
    "SOURCE_PATH",   # s3://.../source=protheus/dataset=products
    "MODE",
    "GLUE_DATABASE",
    "GLUE_TABLE",
])

SOURCE_PATH = args["SOURCE_PATH"].rstrip("/")
MODE = args.get("MODE", "overwrite").lower()
GLUE_DATABASE = args["GLUE_DATABASE"]
GLUE_TABLE = args["GLUE_TABLE"]


def _get_optional_arg(name: str):
    flag = f"--{name}"
    if flag not in sys.argv:
        return None
    idx = sys.argv.index(flag)
    if idx + 1 >= len(sys.argv):
        return None
    value = sys.argv[idx + 1]
    if value.startswith("--"):
        return None
    return value


def _normalize_opt_date(value):
    if value is None:
        return None
    value = str(value).strip()
    if value in ("", "None", "none", "NULL", "null"):
        return None
    return value


def _clean_str(col_name: str):
    return F.when(
        F.trim(F.col(col_name).cast("string")) == "",
        F.lit(None)
    ).otherwise(F.trim(F.col(col_name).cast("string")))


FROM_DATE = _normalize_opt_date(_get_optional_arg("FROM_DATE"))
TO_DATE = _normalize_opt_date(_get_optional_arg("TO_DATE"))

if FROM_DATE is None and TO_DATE is None:
    yesterday = (date.today() - timedelta(days=1)).isoformat()
    FROM_DATE = yesterday
    TO_DATE = yesterday
elif (FROM_DATE is None) ^ (TO_DATE is None):
    raise ValueError("Informe ambos FROM_DATE e TO_DATE (YYYY-MM-DD), ou nenhum.")
else:
    df_ = date.fromisoformat(FROM_DATE)
    dt_ = date.fromisoformat(TO_DATE)
    if dt_ < df_:
        raise ValueError("TO_DATE must be >= FROM_DATE.")


sc = SparkContext.getOrCreate()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

spark.conf.set("spark.sql.sources.partitionOverwriteMode", "dynamic")
spark.conf.set("spark.sql.files.ignoreCorruptFiles", "true")


def get_table_location(database, table_name):
    glue = boto3.client("glue")
    try:
        response = glue.get_table(DatabaseName=database, Name=table_name)
        return response["Table"]["StorageDescriptor"]["Location"].rstrip("/")
    except Exception:
        # fallback padrão similar ao customers
        return f"s3://zrzs-dev-data-lake-silver/domain=silver_erp/source=protheus/dataset={table_name}"


target_path = get_table_location(GLUE_DATABASE, GLUE_TABLE)

print(f"[INFO] Lendo Bronze (Parquet) de {SOURCE_PATH}")
df = (
    spark.read
    .option("basePath", SOURCE_PATH)
    .parquet(f"{SOURCE_PATH}/ingestion_date=*")
)

if FROM_DATE and TO_DATE and "ingestion_date" in df.columns:
    df = df.filter(
        (F.col("ingestion_date") >= F.lit(FROM_DATE)) &
        (F.col("ingestion_date") <= F.lit(TO_DATE))
    )

print("[DEBUG] Schema Bronze (raw):")
df.printSchema()

df_out = (
    df
    .withColumn("source", F.lit("protheus"))
    .withColumn("dataset", F.lit("products"))
    .withColumn("product_code", _clean_str("B1_COD"))
    .withColumn("omie_product_code", _clean_str("B1_XSKUOMI"))
    .withColumn("description", _clean_str("B1_DESC"))
    .withColumn("product_type", _clean_str("B1_TIPO"))
    .withColumn("unit", _clean_str("B1_UM"))
    .withColumn("group_code", _clean_str("B1_GRUPO"))
    .withColumn("ncm", _clean_str("B1_POSIPI"))
    .withColumn("icms_rate", F.col("B1_PICM").cast("double"))
    .withColumn("ipi_rate", F.col("B1_IPI").cast("double"))
    .withColumn("iss_rate", F.col("B1_ALIQISS").cast("double"))
    .withColumn("branch", _clean_str("B1_FILIAL"))
    .withColumn("created_date", F.to_date(F.col("ingestion_date")))
    .withColumn("is_deleted", F.when(F.col("D_E_L_E_T_").cast("string") == "*", F.lit(True)).otherwise(F.lit(False)))
    .withColumn("recno", F.col("R_E_C_N_O_").cast("long"))
    .withColumn("recdel", F.col("R_E_C_D_E_L_").cast("long"))
    .withColumn("updated_at_erp", F.col("S_T_A_M_P_").cast("timestamp"))
)

print("[DEBUG] Schema Silver (normalizado):")
df_out.printSchema()

df_out = df_out.select(
    "source",
    "dataset",
    "product_code",
    "omie_product_code",
    "description",
    "product_type",
    "unit",
    "group_code",
    "ncm",
    "icms_rate",
    "ipi_rate",
    "iss_rate",
    "branch",
    "is_deleted",
    "recno",
    "recdel",
    "updated_at_erp",
    "created_date",
)

(
    df_out
    .repartition("created_date")
    .write.mode(MODE)
    .format("parquet")
    .option("compression", "snappy")
    .partitionBy("created_date")
    .save(target_path)
)

print(f"[SUCCESS] wrote {GLUE_DATABASE}.{GLUE_TABLE} -> {target_path}")
