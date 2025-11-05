# JOB: cdp facebook ads -> Silver
module "glue_job_facebook_ads_to_silver" {
  source = "../glue_job"

  name          = "marketing-facebook-ads-b2s-refine"

  script_bucket = var.etls_bucket
  script_key    = "glue/marketing-facebook-ads-b2s-refine.py"
  temp_bucket   = var.etls_bucket

  data_buckets = [
    var.bronze_bucket,
    var.silver_bucket,
  ]

  use_vpc            = true
  subnet_ids         = var.private_subnet_ids
  security_group_ids = [local.glue_sg_id]

  default_arguments = {
  }

  tags = merge(var.common_tags, {
    Env   = var.environment
    Owner = "data-platform"
  })
}

