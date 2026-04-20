# JOB: Iglu returns bronze -> Silver
module "glue_job_iglu_returns_to_silver" {
  source = "../glue_job"

  name = "commerce-iglu-returns-b2s-refine"

  script_bucket = var.etls_bucket
  script_key    = "glue/commerce-iglu-returns-b2s-refine.py"
  temp_bucket   = var.etls_bucket

  data_buckets = [
    var.bronze_bucket,
    var.silver_bucket,
  ]

  number_of_workers = 2

  use_vpc            = true
  subnet_ids         = var.private_subnet_ids
  security_group_ids = [local.glue_sg_id]

  default_arguments = {
    "--SOURCE_PATH"   = "s3://${var.bronze_bucket}/source=iglu/dataset=returns"
    "--TARGET_PATH"   = "s3://${var.silver_bucket}/domain=commerce/source=iglu/dataset=returns"
    "--SINCE_DAYS"    = "1"
    "--MODE"          = "overwrite"
    "--GLUE_DATABASE" = "silver_commerce"
    "--GLUE_TABLE"    = "iglu_returns"
  }

  tags = merge(var.common_tags, {
    Env   = var.environment
    Owner = "data-platform"
  })
}
