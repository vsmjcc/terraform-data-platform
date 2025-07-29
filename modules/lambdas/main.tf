module "typeform_lambda" {
  source             = "../lambda_function"
  function_name      = "typeform-webhook"
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


locals {
  lambda_modules = {
    typeform   = module.typeform_lambda
  }
}