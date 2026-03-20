output "neo4j_service_name" {
  description = "Nome do serviço ECS do Neo4j"
  value       = aws_ecs_service.neo4j.name
}

output "neo4j_task_definition_arn" {
  description = "ARN da task definition do Neo4j"
  value       = aws_ecs_task_definition.neo4j.arn
}

output "neo4j_security_group_id" {
  description = "ID do Security Group do Neo4j"
  value       = aws_security_group.neo4j.id
}

output "neo4j_log_group_name" {
  description = "Nome do grupo de logs do Neo4j"
  value       = aws_cloudwatch_log_group.neo4j.name
}

output "neo4j_host" {
  value       = "${aws_service_discovery_service.neo4j.name}.${var.service_discovery_namespace_name}"
  description = "DNS do Neo4j via Service Discovery (Ex: neo4j.zerezes.local)"
}

output "neo4j_efs_id" {
  description = "ID do EFS File System usado para persistência"
  value       = aws_efs_file_system.neo4j_data.id
}

output "neo4j_password_secret_arn" {
  description = "ARN do Secret Manager para a senha do Neo4j"
  # O valor vem do recurso que você criou no seu main.tf 
  value = aws_secretsmanager_secret.neo4j_password.arn
}

output "neo4j_password_secret_id" {
  description = "ID (nome) do Secret Manager para a senha do Neo4j"
  value       = aws_secretsmanager_secret.neo4j_password.id
}
