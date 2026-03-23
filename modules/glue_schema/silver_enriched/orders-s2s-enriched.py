"""
S2S Shopify Orders: lê a tabela Silver B2S de orders e gera uma visão refinada
com campos selecionados (order-level), mantendo partição em order_date.
O schema gravado deve ser compatível com a tabela `silver_enriched.orders`
(sem colunas complexas/arrays, para evitar erro de split no Athena).

Destino S3: mesmo layout que customers-s2s-glue — preferencialmente a Location
da tabela no Glue Catalog; se indisponível, fallback para
`s3://<bucket-silver-da-fonte>/domain=silver_enriched/source=conformed/dataset=<GLUE_TABLE>`.
"""
import sys
from typing import Optional
from urllib.parse import urlparse

import boto3
from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from pyspark.context import SparkContext
from pyspark.sql import functions as F


args = getResolvedOptions(
    sys.argv,
    [
        "JOB_NAME",
        "SOURCE_GLUE_DATABASE",
        "SOURCE_GLUE_TABLE",  # ex: shopify_orders_b2s
        "GLUE_DATABASE",
        "GLUE_TABLE",         # ex: shopify_orders_s2s
        "MODE", #
    ],
)

JOB_NAME = args["JOB_NAME"]
SOURCE_GLUE_DATABASE = args["SOURCE_GLUE_DATABASE"]
SOURCE_GLUE_TABLE = args["SOURCE_GLUE_TABLE"]
GLUE_DATABASE = args["GLUE_DATABASE"]
GLUE_TABLE = args["GLUE_TABLE"]
MODE = args.get("MODE", "overwrite").lower()


def _get_opt_arg(name: str):
    flag = f"--{name}"
    if flag not in sys.argv:
        return None
    idx = sys.argv.index(flag)
    if idx + 1 >= len(sys.argv):
        return None
    value = sys.argv[idx + 1]
    if value.startswith("--"):
        return None
    return value.strip()


def _normalize_date_arg(value):
    if value is None:
        return None
    s = (value if isinstance(value, str) else str(value)).strip().lower()
    if s in ("", "none", "null"):
        return None
    return (value if isinstance(value, str) else str(value)).strip()


FROM_ORDER_DATE = _normalize_date_arg(_get_opt_arg("FROM_ORDER_DATE"))
TO_ORDER_DATE = _normalize_date_arg(_get_opt_arg("TO_ORDER_DATE"))


sc = SparkContext.getOrCreate()
glue_context = GlueContext(sc)
spark = glue_context.spark_session

spark.conf.set("spark.sql.sources.partitionOverwriteMode", "dynamic")
spark.conf.set("spark.sql.files.ignoreCorruptFiles", "true")


def ensure_table_and_get_location(glue_db: str, glue_table: str) -> str:
    """Origem B2S: exige tabela no catálogo (sem fallback)."""
    glue = boto3.client("glue")
    tbl = glue.get_table(DatabaseName=glue_db, Name=glue_table)["Table"]
    loc = tbl["StorageDescriptor"]["Location"].rstrip("/")
    print(f"[INFO] Tabela {glue_db}.{glue_table} => {loc}")
    return loc


def get_table_location(
    database: str, table_name: str, source_path_for_bucket: Optional[str] = None
) -> str:
    """
    Destino S2S: Location no Glue Catalog ou fallback alinhado a customers-s2s-glue
    (domain=silver_enriched/source=conformed/dataset=<table_name>).
    """
    glue = boto3.client("glue")
    try:
        tbl = glue.get_table(DatabaseName=database, Name=table_name)["Table"]
        loc = tbl["StorageDescriptor"]["Location"].rstrip("/")
        print(f"[INFO] Destino {database}.{table_name} (Glue) => {loc}")
        return loc
    except Exception as ex:
        print(
            f"[WARN] Não foi possível obter Location de {database}.{table_name}: {ex}. "
            "Usando layout source=conformed (mesmo padrão customers-s2s-glue)."
        )
        bucket = "zrzs-dev-data-lake-silver"
        if source_path_for_bucket:
            b = urlparse(source_path_for_bucket).netloc
            if b:
                bucket = b
        loc = (
            f"s3://{bucket}/"
            f"domain=silver_enriched/source=conformed/dataset={table_name}"
        )
        print(f"[INFO] Destino (fallback) => {loc}")
        return loc

def run_msck_repair(glue_db: str, glue_table: str):
    try:
        print(f"[REPAIR] Executando MSCK REPAIR TABLE {glue_db}.{glue_table}")
        spark.sql(f"MSCK REPAIR TABLE `{glue_db}`.`{glue_table}`")
    except Exception as e:
        print(f"[WARN] Falha no REPAIR de {glue_db}.{glue_table}: {e}")


source_location = ensure_table_and_get_location(SOURCE_GLUE_DATABASE, SOURCE_GLUE_TABLE)

df = (
    spark.read
    .option("basePath", source_location)
    .parquet(f"{source_location}/order_date=*")
)

if FROM_ORDER_DATE and TO_ORDER_DATE:
    df = df.filter(
        (F.col("order_date") >= F.lit(FROM_ORDER_DATE))
        & (F.col("order_date") <= F.lit(TO_ORDER_DATE))
    )

print(f"[DEBUG] orders B2S count after filter: {df.count()}")

df_out = df.select(
    # chaves e datas
    F.col("order_id"),
    F.col("order_date"),
    F.col("created_at"),
    F.col("updated_at"),
    F.col("processed_at"),
    F.col("cancelled_at"),
    F.col("closed_at"),

    # identificação/nomes
    F.col("order_name"),
    F.col("order_number"),
    F.col("number_internal"),

    # status
    F.col("financial_status"),
    F.col("fulfillment_status"),
    F.col("confirmed"),

    # moeda/valores
    F.col("currency"),
    F.col("subtotal_price"),
    F.col("total_price"),
    F.col("total_discounts"),
    F.col("current_total_discounts"),
    F.col("current_total_price"),
)

target_location = get_table_location(GLUE_DATABASE, GLUE_TABLE, source_location)

(
    df_out
    .repartition("order_date")
    .write.mode(MODE)
    .format("parquet")
    .partitionBy("order_date")
    .save(target_location)
)

run_msck_repair(GLUE_DATABASE, GLUE_TABLE)

print(f"[SUCCESS] S2S Shopify Orders gravado em {GLUE_DATABASE}.{GLUE_TABLE} -> {target_location}")

