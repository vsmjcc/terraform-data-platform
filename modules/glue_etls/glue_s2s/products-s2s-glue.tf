# JOB: Orders Items Silver -> Silver Enriched (S2S)
module "glue_job_products_s2s" {
  source = "../../glue_job"

  name = "products-s2s-glue"

  script_bucket = var.etls_bucket
  script_key    = "glue/glue-s2s/products-s2s-glue.py"
  temp_bucket   = var.etls_bucket

  data_buckets = [
    var.silver_bucket,
  ]

  use_vpc            = true
  subnet_ids         = var.private_subnet_ids
  security_group_ids = [var.glue_sg_id]

  default_arguments = {}

  tags = merge(var.common_tags, {
    Env   = var.environment
    Owner = "data-platform"
  })
}