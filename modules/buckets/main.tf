module "bronze_bucket" {
  source          = "../s3_bucket"
  environment     = var.environment
  region          = var.region
  bucket_name     = "zrzs-${var.environment}-data-lake-bronze"
  versioning_enabled = true
  force_destroy      = true
  tags = {
    layer = "bronze"
  }
}

module "silver_bucket" {
  source          = "../s3_bucket"
  environment     = var.environment
  region          = var.region
  bucket_name     = "zrzs-${var.environment}-data-lake-silver"
  versioning_enabled = true
  force_destroy      = true
  tags = {
    layer = "silver"
  }
}

module "gold_bucket" {
  source          = "../s3_bucket"
  environment     = var.environment
  region          = var.region
  bucket_name     = "zrzs-${var.environment}-data-lake-gold"
  versioning_enabled = true
  force_destroy      = true
  tags = {
    layer = "gold"
  }
}

module "packages_bucket" {
  source          = "../s3_bucket"
  environment     = var.environment
  region          = var.region
  bucket_name     = "zrzs-${var.environment}-packages"
  tags = {}
}

resource "aws_s3_object" "lambda_zip" {
  bucket = module.packages_bucket.bucket_name
  key    = "empty-lambda.zip"
  source = "${path.module}/files/empty-lambda.zip"
  etag   = filemd5("${path.module}/files/empty-lambda.zip")
  content_type = "application/zip"
}

module "athena_results_bucket" {
  source          = "../s3_bucket"
  environment     = var.environment
  region          = var.region
  bucket_name     = "zrzs-${var.environment}-athena-results"
  tags = {}
}

module "etls_bucket" {
  source          = "../s3_bucket"
  environment     = var.environment
  region          = var.region
  bucket_name     = "zrzs-${var.environment}-etls"
  tags = {}
}


module "teste_isa" {
  source          = "../s3_bucket"
  environment     = var.environment
  region          = var.region
  bucket_name     = "zrzs-${var.environment}-teste-isa"
  tags = {}
}


locals {
  bucket_modules = {
    bronze          = module.bronze_bucket
    silver          = module.silver_bucket
    gold            = module.gold_bucket
    packages        = module.packages_bucket
    athena_results  = module.athena_results_bucket
    etls            = module.etls_bucket
  }
}
