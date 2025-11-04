# JOB: Shopify -> Silver
module "glue_job_shopify_orders_to_silver" {
  source = "../glue_job"

  name          = "commerce-shopify-orders-b2s-refine"

  script_bucket = var.etls_bucket
  script_key    = "glue/commerce-shopify-orders-b2s-refine.py"
  temp_bucket        = var.etls_bucket

  data_buckets = [
    var.bronze_bucket,
    var.silver_bucket,
  ]
  number_of_workers  = 8
  use_vpc            = true
  subnet_ids         = var.private_subnet_ids
  security_group_ids = [local.glue_sg_id]

  # Só o que muda por job. O submódulo já liga logs/metrics/bookmark.
  default_arguments = {
    "--SOURCE_PATH"           = "s3://${var.bronze_bucket}/domain=commerce/source=shopify/orders"
    "--TARGET_ORDERS_PATH" = "s3://${var.silver_bucket}/domain=commerce/source=shopify/orders"
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
# module "glue_job_shopify_orders_to_silver-crawler" {
#   source       = "../glue_crawler"
#   name         = "commerce-shopify-orders-b2s-refine-crawler"
#   database_name = aws_glue_catalog_database.silver_commerce.name

#   s3_target_paths = [
#     "s3://${var.silver_bucket}/domain=commerce/source=shopify/orders",
#     "s3://${var.silver_bucket}/domain=commerce/source=shopify/order_items",
#     "s3://${var.silver_bucket}/domain=commerce/source=shopify/order_customers",
#     "s3://${var.silver_bucket}/domain=commerce/source=shopify/order_addresses",
#     "s3://${var.silver_bucket}/domain=commerce/source=shopify/order_discount_codes",
#     "s3://${var.silver_bucket}/domain=commerce/source=shopify/order_discount_applications",
#     "s3://${var.silver_bucket}/domain=commerce/source=shopify/order_payments",
#     "s3://${var.silver_bucket}/domain=commerce/source=shopify/order_fulfillments",
#     "s3://${var.silver_bucket}/domain=commerce/source=shopify/order_fulfillment_items",
#   ]



#   read_bucket_arns = ["arn:aws:s3:::${var.silver_bucket}"]
#   read_prefixes = [
#     "domain=commerce/source=shopify/orders/*",
#     "domain=commerce/source=shopify/order_items/*",
#     "domain=commerce/source=shopify/order_customers/*",
#     "domain=commerce/source=shopify/order_addresses/*",
#     "domain=commerce/source=shopify/order_discount_codes/*",
#     "domain=commerce/source=shopify/order_discount_applications/*",
#     "domain=commerce/source=shopify/order_payments/*",
#     "domain=commerce/source=shopify/order_fulfillments/*",
#     "domain=commerce/source=shopify/order_fulfillment_items/*",
#   ]

#   tags = merge(var.common_tags, { step = "bronze-to-silver" })
# }




