locals {
  buckets = ["bronze", "silver", "gold"]
}

resource "aws_s3_bucket" "data_lake" {
  for_each = toset(local.buckets)

  bucket = "${var.bucket_prefix}-${var.environment}-${each.key}"

  tags = {
    Environment = var.environment
    Layer       = each.key
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  for_each = aws_s3_bucket.data_lake

  bucket = each.value.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  for_each = aws_s3_bucket.data_lake

  bucket = each.value.id

  block_public_acls   = true
  ignore_public_acls  = true
  block_public_policy = true
  restrict_public_buckets = true
}
