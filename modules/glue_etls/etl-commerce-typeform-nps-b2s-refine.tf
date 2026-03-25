# JOB: Typeform NPS -> Silver
module "glue_job_typeform_nps_to_silver" {
  source = "../glue_job"

  name = "customer-experience-typeform-nps-b2s-refine"

  script_bucket = var.etls_bucket
  script_key    = "glue/customer-experience-typeform-nps-b2s-refine.py"
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
