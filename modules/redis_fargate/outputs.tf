output "redis_service_name" {
  description = "Nome do serviço ECS do Redis"
  value       = aws_ecs_service.redis.name
}

output "redis_task_definition_arn" {
  description = "ARN da task definition do Redis"
  value       = aws_ecs_task_definition.redis.arn
}

output "redis_security_group_id" {
  description = "ID do Security Group do Redis"
  value       = aws_security_group.redis.id
}

output "redis_log_group_name" {
  description = "Nome do grupo de logs do Redis"
  value       = aws_cloudwatch_log_group.redis.name
}

output "redis_host" {
  value       = "${aws_service_discovery_service.redis.name}.${var.service_discovery_namespace_name}"
  description = "DNS do Redis via Service Discovery"
}
