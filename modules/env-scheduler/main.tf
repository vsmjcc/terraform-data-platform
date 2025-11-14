terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"  # ou use var.aws_region se preferir
}

locals {
  lambda_name = "${var.name_prefix}-lambda"
  role_name   = "${var.name_prefix}-role"
  policy_name = "${var.name_prefix}-policy"
}