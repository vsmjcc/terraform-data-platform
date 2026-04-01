module "glue_job_erp_protheus_products_b2s" {
  source = "../../glue_job"

  name = "erp-protheus-products-b2s"

  script_bucket = var.etls_bucket
  script_key    = "glue/glue-b2s/erp-protheus-products-b2s.py"
  temp_bucket   = var.etls_bucket

  data_buckets = [
    var.bronze_bucket,
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