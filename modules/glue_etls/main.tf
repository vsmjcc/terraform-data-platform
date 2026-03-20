# SG do Glue (cria apenas se não for fornecido)
resource "aws_security_group" "glue" {
  count       = var.glue_sg_id == null ? 1 : 0
  name        = "glue-jobs-${var.environment}"
  description = "SG para AWS Glue"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
    description = "Allow Glue executors to communicate with each other"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, { Environment = var.environment })
}

locals {
  glue_sg_id = var.glue_sg_id != null ? var.glue_sg_id : aws_security_group.glue[0].id
}

module "glue_b2s" {
  source = "./glue_b2s"

  etls_bucket        = var.etls_bucket
  bronze_bucket      = var.bronze_bucket
  silver_bucket      = var.silver_bucket
  private_subnet_ids = var.private_subnet_ids
  common_tags        = var.common_tags
  environment        = var.environment
  vpc_id             = var.vpc_id
  glue_sg_id         = local.glue_sg_id
}

module "glue_s2s" {
  source = "./glue_s2s"

  etls_bucket        = var.etls_bucket
  bronze_bucket      = var.bronze_bucket
  silver_bucket      = var.silver_bucket
  private_subnet_ids = var.private_subnet_ids
  common_tags        = var.common_tags
  environment        = var.environment
  vpc_id             = var.vpc_id
  glue_sg_id         = local.glue_sg_id
}

# # Catálogo (uma vez)
# resource "aws_glue_catalog_database" "silver_commerce" {
#   name = "silver_commerce"
# }

# resource "aws_glue_catalog_database" "silver_marketing" {
#   name = "silver_marketing"
# }

# resource "aws_glue_catalog_database" "silver_analytics" {
#   name = "silver_analytics"
# }

# resource "aws_glue_catalog_database" "silver_finance" {
#   name = "silver_finance"
# }

# # resource "aws_glue_catalog_database" "silver_cx" {
# #   name = "silver_cx"
# # }

# resource "aws_glue_catalog_database" "gold_cx" {
#   name = "gold_cx"
# }

# resource "aws_glue_catalog_database" "silver_offline_analytics" {
#   name = "silver_offline_analytics"
# }

# resource "aws_glue_catalog_database" "silver_people" {
#   name = "silver_people"
# }

