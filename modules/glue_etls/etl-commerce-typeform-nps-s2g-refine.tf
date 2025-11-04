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
    "--SOURCE_PATH"         = "s3://${var.silver_bucket}/domain=customer_experience/source=typeform/dataset=nps"
    "--TARGET_NPS_PATH"     = "s3://${var.gold_bucket}/domain=customer_experience/source=typeform/dataset=nps"
    "--TARGET_ANSWERS_PATH" = "s3://${var.gold_bucket}/domain=customer_experience/source=typeform/dataset=nps_answers"
    "--MODE"                = "overwrite"
    "--SINCE_DAYS"          = "7"
  }

  tags = merge(var.common_tags, {
    Env   = var.environment
    Owner = "data-platform"
  })
}


# # CRAWLER: Typeform (gold)
# module "glue_crawler_typeform_gold" {
#   source        = "../glue_crawler"
#   name          = "customer-experience-typeform-nps-s2g-refine-crawler"
#   database_name = aws_glue_catalog_database.gold_cx.name

#   s3_target_paths = [
#     "s3://${var.gold_bucket}/domain=customer_experience/source=typeform/nps_by_order_date/",
#     "s3://${var.gold_bucket}/domain=customer_experience/source=typeform/nps_by_response_date/",
#   ]

#   read_bucket_arns = ["arn:aws:s3:::${var.gold_bucket}"]
#   read_prefixes = [
#     "domain=customer_experience/source=typeform/nps_by_order_date/*",
#     "domain=customer_experience/source=typeform/nps_by_response_date/*",
#   ]

#   tags = merge(var.common_tags, { step = "silver-to-gold" })
# }
