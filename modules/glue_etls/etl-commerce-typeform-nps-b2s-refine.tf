# JOB: Typeform NPS -> Silver
module "glue_job_typeform_nps_to_silver" {
  source = "../glue_job"

  name          = "customer-experience-typeform-nps-b2s-refine"

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
    "--SOURCE_PATH"         = "s3://${var.bronze_bucket}/domain=customer_experience/source=typeform/dataset=nps"
    "--TARGET_NPS_PATH"     = "s3://${var.silver_bucket}/domain=customer_experience/source=typeform/dataset=nps"
    "--TARGET_ANSWERS_PATH" = "s3://${var.silver_bucket}/domain=customer_experience/source=typeform/dataset=nps_answers"
    "--MODE"                = "overwrite"
    "--SINCE_DAYS"          = "7"
  }

  tags = merge(var.common_tags, {
    Env   = var.environment
    Owner = "data-platform"
  })
}


# CRAWLER: Typeform (silver)
module "glue_crawler_typeform_silver" {
  source        = "../glue_crawler"
  name          = "customer-experience-typeform-nps-b2s-refine-crawler"
  database_name = aws_glue_catalog_database.silver_cx.name

  s3_target_paths = [
    "s3://${var.silver_bucket}/domain=customer_experience/source=typeform/nps/",
    "s3://${var.silver_bucket}/domain=customer_experience/source=typeform/nps_answers/",
  ]

  read_bucket_arns = ["arn:aws:s3:::${var.silver_bucket}"]
  read_prefixes = [
    "domain=customer_experience/source=typeform/nps/*",
    "domain=customer_experience/source=typeform/nps_answers/*",
  ]

  tags = merge(var.common_tags, { step = "bronze-to-silver" })
}
