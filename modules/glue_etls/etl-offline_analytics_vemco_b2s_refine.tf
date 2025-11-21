# JOB: foot_traffic bronze -> Silver
module "glue_job_foot_traffic_to_silver" {
  source = "../glue_job"

  name          = "offline-analytics-foot_traffic-b2s-refine"

  script_bucket = var.etls_bucket
  script_key    = "glue/offline-analytics-foot_traffic-b2s-refine.py"
  temp_bucket   = var.etls_bucket

  data_buckets = [
    var.bronze_bucket,
    var.silver_bucket,
  ]

  # worker_type = "G.8X"
  # number_of_workers = 8

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

