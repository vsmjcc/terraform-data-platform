module "glue_job_typeform_nps_additional_responses_s2s" {
  source = "../../glue_job"

  name = "typeform-nps-additional-responses-s2s"

  script_bucket = var.etls_bucket
  script_key    = "glue/glue-s2s/typeform-nps-additional-responses-s2s-glue.py"
  temp_bucket   = var.etls_bucket

  data_buckets = [
    var.silver_bucket,
  ]

  use_vpc            = true
  subnet_ids         = var.private_subnet_ids
  security_group_ids = [var.glue_sg_id]

  default_arguments = {}

  tags = merge(var.common_tags, {
    Env    = var.environment
    Owner  = "data-platform"
    Layer  = "customer_experience"
    Domain = "typeform"
    Type   = "fact"
  })
}