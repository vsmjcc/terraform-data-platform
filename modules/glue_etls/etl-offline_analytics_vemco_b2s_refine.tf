# JOB: vemco bronze -> Silver
module "glue_job_vemco_to_silver" {
  source = "../glue_job"

  name          = "offline-analytics-vemco-b2s-refine"

  script_bucket = var.etls_bucket
  script_key    = "glue/offline-analytics-vemco-b2s-refine.py"
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


# CRAWLER: vemco (silver)
module "glue_crawler_vemco_silver" {
  source        = "../glue_crawler"
  name          = "offline-analytics-vemco-b2s-refine-crawler"
  database_name = aws_glue_catalog_database.silver_offline_analytics.name

  s3_target_paths = [
    "s3://${var.silver_bucket}/domain=offline_analytics/source=vemco/store_foot_traffic_hourly",
  ]

  read_bucket_arns = ["arn:aws:s3:::${var.silver_bucket}"]
  read_prefixes = [
    "domain=offline_analytics/source=vemco/store_foot_traffic_hourly/*"
  ]

  tags = merge(var.common_tags, { step = "bronze-to-silver" })
}

