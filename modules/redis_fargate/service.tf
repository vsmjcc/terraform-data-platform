
resource "aws_ecs_service" "redis" {
  name            = "redis-${var.environment}"
  cluster         = var.cluster_name
  launch_type     = "FARGATE"
  desired_count   = 1
  task_definition = aws_ecs_task_definition.redis.arn

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.redis.id]
    assign_public_ip = false
  }

  enable_execute_command = true

  service_registries {
    registry_arn = aws_service_discovery_service.redis.arn
  }

  depends_on = [aws_service_discovery_service.redis]

  tags = {
    Environment = var.environment
  }
}