module "glue_job_protheus_customers_b2s" {
  source = "../glue_job"

  name          = "finance-protheus-customers-b2s-glue"

  script_bucket = var.etls_bucket
  script_key    = "glue/glue-b2s/finance-protheus-customers-b2s-glue.py"
  temp_bucket   = var.etls_bucket

  data_buckets = [
    var.bronze_bucket,
    var.silver_bucket,
  ]

  use_vpc            = true
  subnet_ids         = var.private_subnet_ids
  security_group_ids = [local.glue_sg_id]

  default_arguments = {}

  tags = merge(var.common_tags, {
    Env   = var.environment
    Owner = "data-platform"
  })
}