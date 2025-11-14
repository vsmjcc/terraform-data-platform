resource "aws_cloudwatch_log_group" "neo4j" {
  name              = "/ecs/neo4j-${var.environment}"
  retention_in_days = 7
}