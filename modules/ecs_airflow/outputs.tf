output "task_definition_arn" {
  value = aws_ecs_task_definition.airflow.arn
}

output "service_name" {
  value = aws_ecs_service.airflow.name
}