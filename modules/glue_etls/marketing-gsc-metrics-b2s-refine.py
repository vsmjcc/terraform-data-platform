# -*- coding: utf-8 -*-
import sys
import re
from urllib.parse import urlparse
from datetime import date

import boto3
from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from pyspark.context import SparkContext
from pyspark.sql import functions as F
from pyspark.sql.types import (
    StructType,
    StructField,
    StringType,
    ArrayType,
    DoubleType,
)

# ---------------------------
# Args (padrão B2S)
# ---------------------------
args = getResolvedOptions(
    sys.argv,
    [
        "JOB_NAME",
        "SOURCE_PATH",     # s3://<bronze>/source=google_search_console/dataset=<dataset>
        "SINCE_DAYS",      # quantas ingestion_date folders ler (as mais recentes)
        "MODE",            # overwrite | append
        "GLUE_DATABASE",   # db do catálogo Glue (silver_*)
        "GLUE_TABLE",      # tabela Glue (gsc_*)
    ],
)

SOURCE_PATH = args["SOURCE_PATH"].rstrip("/")
SINCE_DAYS = int(args["SINCE_DAYS"])
MODE = args.get("MODE", "overwrite").lower()
GLUE_DATABASE = args["GLUE_DATABASE"]
GLUE_TABLE = args["GLUE_TABLE"]

# ---------------------------
# Optional args (backfill range)
# ---------------------------
def _get_opt_arg(name: str):
    """
    Lê args opcionais no estilo --FROM_DATE YYYY-MM-DD.
    Não usa getResolvedOptions para não exigir presença.
    """
    flag = f"--{name}"
    if flag not in sys.argv:
        return None
    i = sys.argv.index(flag)
    if i + 1 >= len(sys.argv):
        return None
    v = sys.argv[i + 1]
    v = (v or "").strip()
    return v or None


FROM_DATE = _get_opt_arg("FROM_DATE")  # YYYY-MM-DD
TO_DATE = _get_opt_arg("TO_DATE")      # YYYY-MM-DD

# ---------------------------
# Spark / Glue
# ---------------------------
sc = SparkContext.getOrCreate()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

spark.conf.set("spark.sql.sources.partitionOverwriteMode", "dynamic")
spark.conf.set("spark.sql.files.ignoreCorruptFiles", "true")

# ---------------------------
# Helpers
# ---------------------------
def s3_list_latest_ingestion_dates(source_path: str, since_days: int):
    u = urlparse(source_path)
    bucket = u.netloc
    prefix = u.path.lstrip("/")
    s3 = boto3.client("s3")
    paginator = s3.get_paginator("list_objects_v2")
    dates = set()
    for page in paginator.paginate(Bucket=bucket, Prefix=prefix + "/"):
        for obj in page.get("Contents", []):
            key = obj["Key"]
            m = re.search(r"ingestion_date=(\d{4}-\d{2}-\d{2})/", key)
            if m:
                dates.add(m.group(1))
    if not dates:
        return []
    return sorted(dates)[-since_days:]

def s3_list_ingestion_dates_in_range(source_path: str, from_date: str, to_date: str):
    """
    Retorna ingestion_date (YYYY-MM-DD) disponíveis no prefix e filtradas por range (inclusive).
    """
    df = date.fromisoformat(from_date)
    dt = date.fromisoformat(to_date)
    if dt < df:
        raise ValueError(f"TO_DATE must be >= FROM_DATE (got {from_date} -> {to_date})")

    u = urlparse(source_path)
    bucket = u.netloc
    prefix = u.path.lstrip("/")
    s3 = boto3.client("s3")
    paginator = s3.get_paginator("list_objects_v2")
    dates = set()
    for page in paginator.paginate(Bucket=bucket, Prefix=prefix + "/"):
        for obj in page.get("Contents", []):
            key = obj["Key"]
            m = re.search(r"ingestion_date=(\d{4}-\d{2}-\d{2})/", key)
            if m:
                dates.add(m.group(1))
    if not dates:
        return []

    selected = []
    for d in sorted(dates):
        dd = date.fromisoformat(d)
        if df <= dd <= dt:
            selected.append(d)
    return selected


def ensure_table_and_get_location(glue_db: str, glue_table: str) -> str:
    glue = boto3.client("glue")
    try:
        tbl = glue.get_table(DatabaseName=glue_db, Name=glue_table)["Table"]
        loc = tbl["StorageDescriptor"]["Location"].rstrip("/")
        print(f"[INFO] Tabela destino: {loc}")
        return loc
    except glue.exceptions.EntityNotFoundException:
        print(f"[ERRO] Tabela {glue_db}.{glue_table} não existe.")
        sys.exit(1)


def normalize_text(col):
    """
    Remove acentos, coloca em maiúsculo e remove caracteres especiais.
    Mantém apenas A-Z, 0-9 e espaço.
    """
    # remove acentos via translate (mesmo padrão dos jobs GA4)
    c = F.translate(
        F.coalesce(col, F.lit("")),
        "áàãâäéèêëíìîïóòõôöúùûüçÁÀÃÂÄÉÈÊËÍÌÎÏÓÒÕÔÖÚÙÛÜÇ",
        "aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC",
    )
    c = F.upper(F.trim(c))
    c = F.regexp_replace(c, r"[^A-Z0-9 ]+", " ")
    c = F.regexp_replace(c, r"\s+", " ")
    c = F.trim(c)
    return F.when(F.length(c) == 0, F.lit(None)).otherwise(c)

def trim_to_null(col):
    """
    Trim básico (sem normalizar/sem remover acentos).
    Converte string vazia (após trim) em NULL.
    """
    c = F.trim(F.coalesce(col, F.lit("")))
    return F.when(F.length(c) == 0, F.lit(None)).otherwise(c)


# ---------------------------
# Busca pastas ingestion_date
# ---------------------------
if (FROM_DATE is None) ^ (TO_DATE is None):
    raise ValueError("Você deve informar ambos FROM_DATE e TO_DATE (YYYY-MM-DD), ou nenhum (usar SINCE_DAYS).")

if FROM_DATE and TO_DATE:
    ingestion_dates = s3_list_ingestion_dates_in_range(SOURCE_PATH, FROM_DATE, TO_DATE)
    print(f"[INFO] Range mode: {FROM_DATE} → {TO_DATE} | pastas encontradas: {len(ingestion_dates)}")
else:
    ingestion_dates = s3_list_latest_ingestion_dates(SOURCE_PATH, SINCE_DAYS)
    print(f"[INFO] Since-days mode: last {SINCE_DAYS} ingestion_date folders")

if not ingestion_dates:
    print(f"[INFO] Nenhuma pasta ingestion_date= encontrada em {SOURCE_PATH}")
    sys.exit(0)

input_paths = [f"{SOURCE_PATH}/ingestion_date={d}/*.json*" for d in ingestion_dates]
print(f"[INFO] Lendo {len(input_paths)} pastas: {ingestion_dates}")

# ---------------------------
# Schema do JSON (envelope do GSC)
# ---------------------------
row_schema = StructType(
    [
        StructField("keys", ArrayType(StringType(), True), True),
        StructField("clicks", DoubleType(), True),
        StructField("impressions", DoubleType(), True),
    ]
)

raw_schema = StructType(
    [
        StructField("rows", ArrayType(row_schema), True),
    ]
)

params_schema = StructType(
    [
        StructField("site_url", StringType(), True),
        StructField("search_type", StringType(), True),
        StructField("date_from", StringType(), True),
        StructField("date_to", StringType(), True),
        StructField("dimensions", ArrayType(StringType(), True), True),
    ]
)

root_schema = StructType(
    [
        StructField("run_id", StringType(), True),
        StructField("generated_at", StringType(), True),
        StructField("ingestion_date", StringType(), True),
        StructField("dataset", StringType(), True),
        StructField("source", StringType(), True),
        StructField("params", params_schema, True),
        StructField("raw", raw_schema, True),
    ]
)

# ---------------------------
# Leitura com schema + validação
# ---------------------------
print("[INFO] Lendo JSONs com schema...")
df_raw = (
    spark.read.option("multiLine", True)
    .option("mode", "PERMISSIVE")
    .option("columnNameOfCorruptRecord", "_corrupt_record")
    .schema(root_schema)
    .json(input_paths)
)

# Remove arquivos corrompidos
if "_corrupt_record" in df_raw.columns:
    bad = df_raw.filter(F.col("_corrupt_record").isNotNull())
    bad_count = bad.count()
    if bad_count > 0:
        print(f"[WARN] {bad_count} arquivos JSON corrompidos.")
        bad.select("_corrupt_record").show(5, truncate=False)
    df_raw = df_raw.filter(F.col("_corrupt_record").isNull()).drop("_corrupt_record")

# ---------------------------
# Explode rows → colunas
# ---------------------------
print("[INFO] Explodindo rows...")
df_rows = df_raw.select(
    trim_to_null(F.col("run_id")).alias("run_id"),
    trim_to_null(F.col("generated_at")).alias("generated_at"),
    F.col("ingestion_date"),
    trim_to_null(F.col("dataset")).alias("dataset"),
    trim_to_null(F.col("source")).alias("source"),
    trim_to_null(F.col("params.site_url")).alias("site_url"),
    trim_to_null(F.col("params.search_type")).alias("search_type"),
    F.explode_outer("raw.rows").alias("row"),
)

df_flat = df_rows.select(
    F.col("run_id"),
    F.col("generated_at"),
    F.col("ingestion_date"),
    F.col("dataset"),
    F.col("source"),
    F.col("site_url"),
    F.col("search_type"),
    trim_to_null(F.col("row.keys")[0]).alias("date_str"),
    trim_to_null(F.col("row.keys")[1]).alias("query"),
    trim_to_null(F.col("row.keys")[2]).alias("device"),
    F.col("row.clicks").cast("bigint").alias("clicks"),
    F.col("row.impressions").cast("bigint").alias("impressions"),
)

df_tidy = (
    df_flat.withColumn("report_date", F.to_date(F.col("date_str"), "yyyy-MM-dd"))
    .withColumn("ingestion_date", F.to_date("ingestion_date"))
    .withColumn("site_url", trim_to_null(F.col("site_url")))
    .withColumn("search_type", F.upper(trim_to_null(F.col("search_type"))))
    .withColumn("dataset", trim_to_null(F.col("dataset")))
    .withColumn("source", trim_to_null(F.col("source")))
    .withColumn("query", normalize_text(F.col("query")))
    .withColumn("device", normalize_text(F.col("device")))
    .withColumn("clicks", F.coalesce(F.col("clicks"), F.lit(0)).cast("bigint"))
    .withColumn("impressions", F.coalesce(F.col("impressions"), F.lit(0)).cast("bigint"))
    .select(
        "report_date",
        "query",
        "device",
        "clicks",
        "impressions",
        "site_url",
        "search_type",
        "ingestion_date",
        "run_id",
        "generated_at",
        "dataset",
        "source",
    )
    .filter("report_date IS NOT NULL")
    .dropDuplicates(["site_url", "search_type", "query", "device", "report_date"])
)

# ---------------------------
# Escrita em Parquet (particionado)
# ---------------------------
target_location = ensure_table_and_get_location(GLUE_DATABASE, GLUE_TABLE)
df_tidy = df_tidy.cache()

partitions = df_tidy.select("report_date").distinct().collect()
print(f"[INFO] Partições a escrever: {[r.report_date for r in partitions]}")

print("[DEBUG] Schema final:")
df_tidy.printSchema()
print(f"[DEBUG] Total de linhas: {df_tidy.count()}")

print(f"[INFO] Escrevendo em {target_location} (modo: {MODE})...")
(
    df_tidy.repartition("report_date")
    .write.mode(MODE)
    .format("parquet")
    .option("compression", "snappy")
    .partitionBy("report_date")
    .save(target_location)
)

print("[INFO] Job GSC (Bronze → Silver normalization) concluído com sucesso!")

