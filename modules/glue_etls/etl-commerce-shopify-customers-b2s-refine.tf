# JOB: Shopify -> Silver
module "glue_job_shopify_customers_to_silver" {
  source = "../glue_job"

  name          = "commerce-shopify-customers-b2s-refine"

  script_bucket = var.etls_bucket
  script_key    = "glue/commerce-shopify-customers-b2s-refine.py"
  temp_bucket        = var.etls_bucket

  data_buckets = [
    var.bronze_bucket,
    var.silver_bucket,
  ]

  use_vpc            = true
  subnet_ids         = var.private_subnet_ids
  security_group_ids = [local.glue_sg_id]

  # Só o que muda por job. O submódulo já liga logs/metrics/bookmark.
  default_arguments = {
    "--SOURCE_PATH"           = "s3://${var.bronze_bucket}/domain=commerce/source=shopify/customers"
    "--TARGET_CUSTOMERS_PATH" = "s3://${var.silver_bucket}/domain=commerce/source=shopify/customers"
    "--TARGET_ADDRESSES_PATH" = "s3://${var.silver_bucket}/domain=commerce/source=shopify/customer_addresses"
    "--MODE"                  = "overwrite"
    "--SINCE_DAYS"            = "7"
    # Se precisar, você pode incluir:
    # "--conf" = "spark.sql.sources.partitionOverwriteMode=dynamic"
  }

  tags = merge(var.common_tags, {
    Env   = var.environment
    Owner = "data-platform"
  })
}


# # CRAWLER: Shopify (silver)
# module "glue_crawler_shopify_silver" {
#   source       = "../glue_crawler"
#   name         = "commerce-shopify-customers-b2s-refine-crawler"
#   database_name = aws_glue_catalog_database.silver_commerce.name

#   s3_target_paths = [
#     "s3://${var.silver_bucket}/domain=commerce/source=shopify/customers/",
#     "s3://${var.silver_bucket}/domain=commerce/source=shopify/customer_addresses/",
#   ]

#   read_bucket_arns = ["arn:aws:s3:::${var.silver_bucket}"]
#   read_prefixes = [
#     "domain=commerce/source=shopify/customers/*",
#     "domain=commerce/source=shopify/customer_addresses/*",
#   ]

#   tags = merge(var.common_tags, { step = "bronze-to-silver" })
# }
