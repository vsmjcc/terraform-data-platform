resource "aws_s3_bucket" "test_bucket" {
  bucket = "zerezes-data-dev-test-bucket"
  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

