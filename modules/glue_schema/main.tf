resource "aws_glue_catalog_database" "silver_cx2" {
  name = "silver_cx2"
}
  
module "silver_cx" {
  source = "./silver_cx"

  environment   = var.environment
  bucket        = var.silver_bucket
  database_name = aws_glue_catalog_database.silver_cx2.name
  domain        = "customer_experience"
}