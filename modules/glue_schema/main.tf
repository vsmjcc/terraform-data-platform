resource "aws_glue_catalog_database" "silver_cx" {
  name = "silver_cx"
}
  
resource "aws_glue_catalog_database" "silver_commerce" {
  name = "silver_commerce"
}

resource "aws_glue_catalog_database" "silver_marketing" {
  name = "silver_marketing"
}

resource "aws_glue_catalog_database" "silver_analytics" {
  name = "silver_analytics"
}

resource "aws_glue_catalog_database" "silver_erp" {
  name = "silver_erp"
}

resource "aws_glue_catalog_database" "silver_enriched" {
  name = "silver_enriched"
}

resource "aws_glue_catalog_database" "silver_offline_analytics" {
  name = "silver_offline_analytics"
}

resource "aws_glue_catalog_database" "silver_people" {
  name = "silver_people"
}

resource "aws_glue_catalog_database" "gold_cx" {
  name = "gold_cx"
}

resource "aws_glue_catalog_database" "gold_analytics" {
  name = "gold_analytics"
}

resource "aws_glue_catalog_database" "gold_marketing" {
  name = "gold_marketing"
}

resource "aws_glue_catalog_database" "gold" {
  name = "gold"
}


module "silver_cx" {
  source = "./silver_cx"

  environment   = var.environment
  bucket        = var.silver_bucket
  database_name = aws_glue_catalog_database.silver_cx.name
  domain        = "customer_experience"
}

module "silver_commerce" {
  source = "./silver_commerce"

  environment   = var.environment
  bucket        = var.silver_bucket
  database_name = aws_glue_catalog_database.silver_commerce.name
  domain        = "commerce"
}

module "silver_marketing" {
  source = "./silver_marketing"

  environment   = var.environment
  bucket        = var.silver_bucket
  database_name = aws_glue_catalog_database.silver_marketing.name
  domain        = "marketing"
}

module "silver_analytics" {
  source = "./silver_analytics"

  environment   = var.environment
  bucket        = var.silver_bucket
  database_name = aws_glue_catalog_database.silver_analytics.name
  domain        = "analytics"
}


module "silver_erp" {
  source = "./silver_erp"

  environment   = var.environment
  bucket        = var.silver_bucket
  database_name = aws_glue_catalog_database.silver_erp.name
  domain        = "silver_erp"
}

module "silver_enriched" {
  source = "./silver_enriched"

  environment   = var.environment
  bucket        = var.silver_bucket
  database_name = aws_glue_catalog_database.silver_enriched.name
  domain        = "silver_enriched"
}


module "silver_offline_analytics" {
  source = "./silver_offline_analytics"

  environment   = var.environment
  bucket        = var.silver_bucket
  database_name = aws_glue_catalog_database.silver_offline_analytics.name
  domain        = "offline_analytics"
}


module "silver_people" {
  source = "./silver_people"

  environment   = var.environment
  bucket        = var.silver_bucket
  database_name = aws_glue_catalog_database.silver_people.name
  domain        = "people"
}

module "gold_cx" {
  source = "./gold_cx"

  environment   = var.environment
  bucket        = var.gold_bucket
  database_name = aws_glue_catalog_database.gold_cx.name
  domain        = "customer_experience"
}

module "gold_analytics" {
  source = "./gold_analytics"

  environment   = var.environment
  bucket        = var.gold_bucket
  database_name = aws_glue_catalog_database.gold_analytics.name
  domain        = "analytics"
}

module "gold_marketing" {
  source = "./gold_marketing"

  environment   = var.environment
  bucket        = var.gold_bucket
  database_name = aws_glue_catalog_database.gold_marketing.name
  domain        = "marketing"
}

module "gold" {
  source = "./gold"

  environment   = var.environment
  bucket        = var.gold_bucket
  database_name = aws_glue_catalog_database.gold.name
  domain        = "gold"
}

