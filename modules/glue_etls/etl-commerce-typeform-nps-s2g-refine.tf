# JOB: Typeform NPS -> Silver
module "glue_job_typeform_nps_to_gold" {
  source = "../glue_job"

  name          = "customer-experience-typeform-nps-s2g-refine"

  script_bucket = var.etls_bucket
  script_key    = "glue/customer-experience-typeform-nps-s2g-refine.py"
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

