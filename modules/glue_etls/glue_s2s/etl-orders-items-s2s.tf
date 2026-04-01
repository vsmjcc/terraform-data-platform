# JOB: Orders Items Silver -> Silver Enriched (S2S)
module "glue_job_orders_items_s2s_enriched" {
  source = "../../glue_job"

  name = "orders-items-s2s-enriched"

  script_bucket = var.etls_bucket
  script_key    = "glue/glue-s2s/orders-items-s2s-glue.py"
  temp_bucket   = var.etls_bucket

  data_buckets = [
    var.silver_bucket,
  ]

  use_vpc            = true
  subnet_ids         = var.private_subnet_ids
  security_group_ids = [var.glue_sg_id]

  default_arguments = {
    "--SHOPIFY_GLUE_DATABASE"  = "silver_commerce"
    "--SHOPIFY_GLUE_TABLE"     = "order_items"
    "--OMIE_GLUE_DATABASE"     = "silver_erp"
    "--OMIE_GLUE_TABLE"        = "omie_document_items_refined"
    "--PROTHEUS_GLUE_DATABASE" = "silver_erp"
    "--PROTHEUS_GLUE_TABLE"    = "nf_out_items"
    "--GLUE_DATABASE"          = "silver_enriched"
    "--GLUE_TABLE"             = "orders_items_enriched"
    "--MODE"                   = "overwrite"
  }

  tags = merge(var.common_tags, {
    Env   = var.environment
    Owner = "data-platform"
  })
}