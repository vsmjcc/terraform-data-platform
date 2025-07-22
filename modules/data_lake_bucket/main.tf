resource "aws_s3_bucket" "this" {
  bucket = "${var.bucket_prefix}-${var.environment}-${var.layer}"

  tags = {
    Environment = var.environment
    Layer       = var.layer
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.bucket

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.bucket

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}