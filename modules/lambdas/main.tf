  module "typeform_lambda" {
    source             = "../lambda_function"
    function_name      = "ingest-typeform-to-bronze"
    handler            = "main.handler"
    runtime            = "python3.11"
    timeout            = 10
    memory_size        = 128

    s3_bucket          = var.packages_bucket_name
    s3_key             = "empty-lambda.zip"

    enable_http_api    = true
    public_access      = true
    enable_custom_domain = true
    dns_zone_id         = var.dns_zones["data_zerezes"].zone_id
    dns_certificate_arn = var.dns_zones["data_zerezes"].certificate_arn

    environment           = var.environment
    region                = var.region

    environment_variables = {
      STAGE     = var.environment
      LOG_LEVEL = "debug"
      S3_BUCKET               = var.bronze_bucket_name
      TYPEFORM_WEBHOOK_SECRET = "3f2c49f7e5af99c7129931072111d34f85a69cea"
    }
  }

module "shopify_orders_lambda" {
  source             = "../lambda_function"
  function_name      = "ingest-shopify-orders-to-bronze"
  handler            = "main.handler"
  runtime            = "python3.11"
  timeout            = 10
  memory_size        = 128

  s3_bucket          = var.packages_bucket_name
  s3_key             = "empty-lambda.zip"

  enable_http_api     = true
  public_access       = true
  enable_custom_domain = true
  dns_zone_id         = var.dns_zones["data_zerezes"].zone_id
  dns_certificate_arn = var.dns_zones["data_zerezes"].certificate_arn

  environment           = var.environment
  region                = var.region

  environment_variables = {
    STAGE                   = var.environment
    LOG_LEVEL               = "debug"
    S3_BUCKET               = var.bronze_bucket_name
    SHOPIFY_WEBHOOK_SECRET = "83b515a54539d8adda6a577d85346fc0b909f1237c38ecebc0038e22e701ce1a"
  }
}

module "shopify_products_lambda" {
  source             = "../lambda_function"
  function_name      = "ingest-shopify-products-to-bronze"
  handler            = "main.handler"
  runtime            = "python3.11"
  timeout            = 10
  memory_size        = 128

  s3_bucket          = var.packages_bucket_name
  s3_key             = "empty-lambda.zip"

  enable_http_api     = true
  public_access       = true
  enable_custom_domain = true
  dns_zone_id         = var.dns_zones["data_zerezes"].zone_id
  dns_certificate_arn = var.dns_zones["data_zerezes"].certificate_arn

  environment           = var.environment
  region                = var.region

  environment_variables = {
    STAGE                   = var.environment
    LOG_LEVEL               = "debug"
    S3_BUCKET               = var.bronze_bucket_name
    SHOPIFY_WEBHOOK_SECRET = "83b515a54539d8adda6a577d85346fc0b909f1237c38ecebc0038e22e701ce1a"
  }
}

module "shopify_customers_lambda" {
  source             = "../lambda_function"
  function_name      = "ingest-shopify-customers-to-bronze"
  handler            = "main.handler"
  runtime            = "python3.11"
  timeout            = 10
  memory_size        = 128

  s3_bucket          = var.packages_bucket_name
  s3_key             = "empty-lambda.zip"

  enable_http_api     = true
  public_access       = true
  enable_custom_domain = true
  dns_zone_id         = var.dns_zones["data_zerezes"].zone_id
  dns_certificate_arn = var.dns_zones["data_zerezes"].certificate_arn

  environment           = var.environment
  region                = var.region

  environment_variables = {
    STAGE                   = var.environment
    LOG_LEVEL               = "debug"
    S3_BUCKET               = var.bronze_bucket_name
    SHOPIFY_WEBHOOK_SECRET = "83b515a54539d8adda6a577d85346fc0b909f1237c38ecebc0038e22e701ce1a"
  }
}

module "invoice_search_lambda" {
  source             = "../lambda_function"
  function_name      = "invoice-search"
  handler            = "main.handler"
  runtime            = "python3.11"
  timeout            = 10
  memory_size        = 128

  s3_bucket          = "zrzs-${var.environment}-packages"
  s3_key             = "empty-lambda.zip"

  enable_http_api      = true
  public_access        = true
  enable_custom_domain = true
  dns_zone_id          = var.dns_zones["data_zerezes"].zone_id
  dns_certificate_arn  = var.dns_zones["data_zerezes"].certificate_arn

  environment          = var.environment
  region               = var.region

  environment_variables = {
    STAGE     = var.environment
    LOG_LEVEL = "debug"

    ATHENA_DATABASE   = "silver_erp"
    ATHENA_WORKGROUP  = "primary"
    ATHENA_OUTPUT_S3  = "s3://zrzs-${var.environment}-athena-results/invoice-search/"

    DOCS_TABLE        = "omie_documents"
    ITEMS_TABLE       = "omie_document_items"
    PAYMENTS_TABLE    = "omie_document_payments"

    DEFAULT_PAGE_SIZE = "50"
    MAX_PAGE_SIZE     = "200"

    API_KEY            = "d9a59303-6fce-4a19-9438-4fe8be44ee11"
    API_KEY_PARAM_NAME = "api_key"
  }

  # === PERMISSÕES CHAPADAS DEV (Athena + Glue + S3 results + S3 silver) ===
  inline_policies = {
    "invoice-search-athena-glue-s3-dev" = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid    = "AthenaRunQueries"
          Effect = "Allow"
          Action = [
            "athena:StartQueryExecution",
            "athena:GetQueryExecution",
            "athena:GetQueryResults",
            "athena:GetWorkGroup"
          ]
          Resource = "*"
        },
        {
          Sid    = "GlueCatalogRead"
          Effect = "Allow"
          Action = [
            "glue:GetDatabase",
            "glue:GetDatabases",
            "glue:GetTable",
            "glue:GetTables",
            "glue:GetPartition",
            "glue:GetPartitions"
          ]
          Resource = "*"
        },
        {
          Sid    = "S3AthenaResultsBucket"
          Effect = "Allow"
          Action = ["s3:ListBucket", "s3:GetBucketLocation"]
          Resource = "arn:aws:s3:::zrzs-${var.environment}-athena-results"
        },
        {
          Sid    = "S3AthenaResultsObjects"
          Effect = "Allow"
          Action = ["s3:GetObject", "s3:PutObject"]
          Resource = "arn:aws:s3:::zrzs-${var.environment}-athena-results/*"
        },
        {
          Sid    = "S3SilverBucket"
          Effect = "Allow"
          Action = ["s3:ListBucket", "s3:GetBucketLocation"]
          Resource = "arn:aws:s3:::zrzs-${var.environment}-data-lake-silver"
        },
        {
          Sid    = "S3SilverReadAll"
          Effect = "Allow"
          Action = ["s3:GetObject"]
          Resource = "arn:aws:s3:::zrzs-${var.environment}-data-lake-silver/*"
        }
      ]
    })
  }
}

module "airflow_dags_sync_lambda" {
  source             = "../lambda_function"
  function_name      = "dags-sync-to-efs"
  handler            = "main.handler"
  runtime            = "python3.11"
  timeout            = 300
  memory_size        = 512

  s3_bucket          = var.packages_bucket_name
  s3_key             = "empty-lambda.zip"

  enable_http_api    = false 
  public_access      = false

  vpc_id             = var.vpc_id
  subnet_ids         = var.private_subnet_ids
  #security_group_ids = [var.volumes["airflow_dags"].security_group_id]

  efs_arn            = var.volumes["airflow_dags"].efs_arn
  efs_mount_path     = "/mnt/efs"
  efs_security_group_id = var.volumes["airflow_dags"].security_group_id
  allow_efs_ingress     = true

  environment           = var.environment
  region                = var.region

  environment_variables = {
    DAG_BUCKET      = "zrzs-${var.environment}-packages"
    DAG_DESTINATION = "/mnt/efs"
  }
}

locals {
  lambda_modules = {
    typeform          = module.typeform_lambda
    shopify_orders    = module.shopify_orders_lambda
    shopify_products  = module.shopify_products_lambda
    shopify_customers = module.shopify_customers_lambda
    invoice_search    = module.invoice_search_lambda
    
    # airflow_dags_sync = module.airflow_dags_sync_lambda
  }
}
