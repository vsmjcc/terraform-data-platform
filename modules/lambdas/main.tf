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

    environment_variables = {
      STAGE     = var.environment
      LOG_LEVEL = "debug"
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

  enable_http_api    = true
  public_access      = true

  environment_variables = {
    STAGE     = var.environment
    LOG_LEVEL = "debug"
    S3_BUCKET  = var.bronze_bucket_name
  }
}


module "airflow_dags_sync_lambda" {
  source             = "../lambda_function"
  function_name      = "airflow-dags-sync-to-efs"
  handler            = "handler.lambda_handler"
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

  environment_variables = {
    DAG_BUCKET      = "zrzs-dev-packages"
    DAG_DESTINATION = "/mnt/efs"
  }
}

locals {
  lambda_modules = {
    typeform          = module.typeform_lambda
    shopify_orders    = module.shopify_orders_lambda
    airflow_dags_sync = module.airflow_dags_sync_lambda
  }
}