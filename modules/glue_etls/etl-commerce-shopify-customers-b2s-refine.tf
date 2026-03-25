# JOB: Shopify -> Silver
module "glue_job_shopify_customers_to_silver" {
  source = "../glue_job"

  name = "commerce-shopify-customers-b2s-refine"

  script_bucket = var.etls_bucket
  script_key    = "glue/commerce-shopify-customers-b2s-refine.py"
  temp_bucket   = var.etls_bucket

  data_buckets = [
    var.bronze_bucket,
    var.silver_bucket,
  ]

  use_vpc            = true
  subnet_ids         = var.private_subnet_ids
  security_group_ids = [local.glue_sg_id]

  # Só o que muda por job. O submódulo já liga logs/metrics/bookmark.
  default_arguments = {

  }

  tags = merge(var.common_tags, {
    Env   = var.environment
    Owner = "data-platform"
  })
}
