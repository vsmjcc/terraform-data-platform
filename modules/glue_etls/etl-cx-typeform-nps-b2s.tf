# JOB: CX Typeform NPS form_responses -> Silver
module "glue_job_cx-typeform-nps-b2s" {
  source = "../glue_job"

  name = "cx-typeform-nps-b2s"

  script_bucket = var.etls_bucket
  script_key    = "glue/cx-typeform-nps-b2s.py"
  temp_bucket   = var.etls_bucket

  data_buckets = [
    var.bronze_bucket,
    var.silver_bucket,
  ]

  use_vpc            = true
  subnet_ids         = var.private_subnet_ids
  security_group_ids = [local.glue_sg_id]

  default_arguments = {
    "--SOURCE_PATH"   = "s3://${var.bronze_bucket}/source=typeform/dataset=nps_form"
    "--GLUE_DATABASE" = "silver_cx"
    "--GLUE_TABLE"    = "nps_form"
    "--MODE"          = "overwrite"
  }

  tags = merge(var.common_tags, {
    Env   = var.environment
    Owner = "data-platform"
  })
}

