
resource "aws_cloudwatch_log_group" "elasticsearch" {
  name              = "/ecs/${var.name}-${var.environment}"
  retention_in_days = 7
}