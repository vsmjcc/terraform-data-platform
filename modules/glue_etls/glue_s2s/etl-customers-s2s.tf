module "glue_job_customers_s2s" {
  source = "../../glue_job"

  name = "customers-s2s-glue"

  script_bucket = var.etls_bucket
  script_key    = "glue/glue-s2s/customers-s2s-glue.py"
  temp_bucket   = var.etls_bucket

  data_buckets = [
    var.silver_bucket,
  ]

  use_vpc            = true
  subnet_ids         = var.private_subnet_ids
  security_group_ids = [var.glue_sg_id]

  default_arguments = {}

  tags = merge(var.common_tags, {
    Env    = var.environment
    Owner  = "data-platform"
    Layer  = "silver_enriched"
    Domain = "commerce"
    Type   = "dimension"
  })
}