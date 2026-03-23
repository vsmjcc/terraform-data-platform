# JOB: cdp google_analytics ga4_cost -> Silver

module "glue_job_ga4_cost_to_silver" {
  source = "../glue_job"

  name = "analytics-ga4-cost-b2s-refine"

  script_bucket = var.etls_bucket
  script_key    = "glue/analytics-ga4-cost-b2s-refine.py"
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


# JOB: cdp google_analytics ga4_sessions -> Silver

module "glue_job_ga4_sessions_to_silver" {
  source = "../glue_job"

  name = "analytics-ga4-sessions-b2s-refine"

  script_bucket = var.etls_bucket
  script_key    = "glue/analytics-ga4-sessions-b2s-refine.py"
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


# JOB: cdp google_analytics ga4_transactions -> Silver

module "glue_job_ga4_transactions_to_silver" {
  source = "../glue_job"

  name = "analytics-ga4-transactions-b2s-refine"

  script_bucket = var.etls_bucket
  script_key    = "glue/analytics-ga4-transactions-b2s-refine.py"
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



