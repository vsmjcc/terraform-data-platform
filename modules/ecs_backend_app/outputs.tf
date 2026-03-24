output "service_name" {
  description = "Nome do serviço ECS."
  value       = aws_ecs_service.app.name
}

output "task_definition_arn" {
  description = "ARN da task definition."
  value       = aws_ecs_task_definition.app.arn
}

output "url" {
  description = "URL pública da aplicação."
  value       = "https://${local.domain_name}"
}

output "ecr_repository_name" {
  description = "Nome do repositório ECR criado pelo módulo."
  value       = var.create_ecr_repository ? aws_ecr_repository.app[0].name : null
}

output "ecr_repository_url" {
  description = "URL do repositório ECR criado pelo módulo."
  value       = var.create_ecr_repository ? aws_ecr_repository.app[0].repository_url : null
}

output "container_image" {
  description = "Imagem efetivamente usada pela task ECS."
  value       = local.resolved_container_image
}