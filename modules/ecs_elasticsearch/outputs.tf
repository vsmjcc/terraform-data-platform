output "elasticsearch_service_name" {
  description = "Nome do serviço ECS do Elasticsearch"
  value       = aws_ecs_service.elasticsearch.name
}

output "elasticsearch_task_definition_arn" {
  description = "ARN da task definition do Elasticsearch"
  value       = aws_ecs_task_definition.elasticsearch.arn
}

output "elasticsearch_security_group_id" {
  description = "ID do Security Group do Elasticsearch"
  value       = aws_security_group.elasticsearch.id
}

output "elasticsearch_log_group_name" {
  description = "Nome do grupo de logs do Elasticsearch"
  value       = aws_cloudwatch_log_group.elasticsearch.name
}

output "elasticsearch_host" {
  value       = "${aws_service_discovery_service.elasticsearch.name}.${var.service_discovery_namespace_name}"
  description = "DNS do Elasticsearch via Service Discovery (Ex: elasticsearch.zerezes.local)"
}

output "elasticsearch_efs_id" {
  description = "ID do EFS File System usado para persistência"
  value       = aws_efs_file_system.es_data.id
}

output "elasticsearch_password_secret_arn" {
  description = "ARN do Secret Manager para a senha do Elasticsearch"
  value       = aws_secretsmanager_secret.es_password.arn
}