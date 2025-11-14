resource "aws_cloudwatch_log_group" "airflow" {
  name              = "/ecs/airflow-${var.environment}-v2"
  retention_in_days = 7
  skip_destroy      = true

  tags = { Environment = var.environment }
}

module "airflow_logs_bucket" {
  source      = "../s3_bucket"
  environment = var.environment
  region      = var.aws_region
  bucket_name = "zrzs-${var.environment}-airflow-logs"
  tags        = { Environment = var.environment }
}