# ============================================================
# JOB: analytics ga4_sessions -> Gold (Dimensions)
# ============================================================

module "glue_job_ga4_sessions_dim_to_gold" {
  source = "../glue_job"

  name          = "analytics-ga4-sessions-dim-s2g"

  script_bucket = var.etls_bucket
  script_key    = "glue/analytics-ga4-sessions-dim-s2g.py"
  temp_bucket   = var.etls_bucket

  data_buckets = [
    var.silver_bucket,
    var.gold_bucket,
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


# ============================================================
# JOB: analytics ga4_sessions -> Gold (Fact)
# ============================================================

module "glue_job_ga4_sessions_fact_to_gold" {
  source = "../glue_job"

  name          = "analytics-ga4-sessions-fact-s2g"

  script_bucket = var.etls_bucket
  script_key    = "glue/analytics-ga4-sessions-fact-s2g.py"
  temp_bucket   = var.etls_bucket

  data_buckets = [
    var.silver_bucket,
    var.gold_bucket,
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
