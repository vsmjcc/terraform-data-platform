resource "aws_iam_policy" "data_lake_files_rw" {
  name        = "zrzs-${var.environment}-data-lake-settings-rw"
  description = "Permite leitura e escrita no bucket data-lake-files para o backend do data-lake-settings"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "ListBucket",
        Effect = "Allow",
        Action = [
          "s3:ListBucket"
        ],
        Resource = "arn:aws:s3:::zrzs-${var.environment}-data-lake-settings"
      },
      {
        Sid    = "ReadWriteObjects",
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Resource = "arn:aws:s3:::zrzs-${var.environment}-data-lake-settings/*"
      }
    ]
  })

  tags = var.tags
}