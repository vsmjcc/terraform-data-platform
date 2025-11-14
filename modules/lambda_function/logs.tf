resource "aws_cloudwatch_log_group" "lambda" {
  count             = var.create_log_group ? 1 : 0
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_in_days
}