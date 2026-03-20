
resource "aws_s3_bucket_policy" "bronze_bucket_policy" {
  bucket = "zrzs-${var.environment}-data-lake-bronze"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid : "AllowPutFromIngestToBronze",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:PutObject",
        Resource  = "arn:aws:s3:::zrzs-${var.environment}-data-lake-bronze/*",
        Condition = {
          StringLike = {
            "aws:PrincipalArn" = "arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/ingest-*-to-bronze-lambda-role/*"
          }
        }
      }
    ]
  })
}