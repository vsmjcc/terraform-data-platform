
resource "aws_cloudwatch_log_group" "redis" {
  name              = "/ecs/redis-${var.environment}"
  retention_in_days = 7
}