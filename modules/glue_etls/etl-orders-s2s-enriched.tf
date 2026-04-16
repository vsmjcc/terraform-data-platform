# JOB: Orders Silver B2S -> Silver Enriched (S2S)
module "glue_job_orders_s2s_enriched" {
  source = "../glue_job"

  name = "orders-s2s-enriched"

  script_bucket = var.etls_bucket
  script_key    = "glue/glue-s2s/orders-s2s-enriched.py"
  temp_bucket   = var.etls_bucket

  data_buckets = [
    var.silver_bucket,
  ]

  use_vpc            = true
  subnet_ids         = var.private_subnet_ids
  security_group_ids = [local.glue_sg_id]

  default_arguments = {
    "--SOURCE_GLUE_DATABASE" = "silver_commerce"
    "--SOURCE_GLUE_TABLE"    = "orders"
    "--GLUE_DATABASE"        = "silver_enriched"
    "--GLUE_TABLE"           = "orders"
    "--MODE"                 = "overwrite"
  }

  tags = merge(var.common_tags, {
    Env   = var.environment
    Owner = "data-platform"
  })
}
