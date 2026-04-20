# JOB: cdp google_analytics ga4_sessions silver_analytics -> silver_enriched

module "glue_job_ga4_sessions_to_enriched" {
  source = "../glue_job"

  name = "analytics-ga4-sessions-s2s-enrich"

  script_bucket = var.etls_bucket
  script_key    = "glue/glue-s2s/analytics-ga4-sessions-s2s-enrich.py"
  temp_bucket   = var.etls_bucket

  data_buckets = [
    var.silver_bucket,
    "zrzs-${var.environment}-data-lake-settings",
  ]

  use_vpc            = true
  subnet_ids         = var.private_subnet_ids
  security_group_ids = [local.glue_sg_id]

  default_arguments = {
    "--CHANNEL_RULES_BUCKET" = "zrzs-${var.environment}-data-lake-settings"
    "--CHANNEL_RULES_KEY"    = "channel-classification/current.json"
    "--CHANNEL_RULES_REGION" = var.region
  }

  tags = merge(var.common_tags, {
    Env   = var.environment
    Owner = "data-platform"
  })
}


# JOB: cdp google_analytics ga4_transactions silver_analytics -> silver_enriched

module "glue_job_ga4_transactions_to_enriched" {
  source = "../glue_job"

  name = "analytics-ga4-transactions-s2s-enrich"

  script_bucket = var.etls_bucket
  script_key    = "glue/glue-s2s/analytics-ga4-transactions-s2s-enrich.py"
  temp_bucket   = var.etls_bucket

  data_buckets = [
    var.silver_bucket,
    "zrzs-${var.environment}-data-lake-settings",
  ]

  use_vpc            = true
  subnet_ids         = var.private_subnet_ids
  security_group_ids = [local.glue_sg_id]

  default_arguments = {
    "--CHANNEL_RULES_BUCKET" = "zrzs-${var.environment}-data-lake-settings"
    "--CHANNEL_RULES_KEY"    = "channel-classification/current.json"
    "--CHANNEL_RULES_REGION" = var.region
  }

  tags = merge(var.common_tags, {
    Env   = var.environment
    Owner = "data-platform"
  })
}
