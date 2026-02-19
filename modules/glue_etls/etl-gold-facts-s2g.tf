# ============================================================
# GOLD - FACT GSC METRICS
# ============================================================
# Lê Silver (gsc_metrics_enriched), junta com dim_device_gsc e dim_query_gsc,
# agrega clicks/impressions por (date, device_id, query_id) e grava na fato.
# ============================================================

module "glue_job_fact_gsc_metrics_s2g" {
  source = "../glue_job"

  name          = "fact-gsc-metrics-s2g"
  script_bucket = var.etls_bucket
  script_key    = "glue/facts/fact_gsc_metrics_s2g.py"
  temp_bucket   = var.etls_bucket

  data_buckets = [
    var.silver_bucket,
    var.gold_bucket,
  ]

  use_vpc            = true
  subnet_ids         = var.private_subnet_ids
  security_group_ids = [local.glue_sg_id]

  default_arguments = {}

  tags = merge(var.common_tags, {
    Layer = "gold"
    Type  = "fact"
  })
}
