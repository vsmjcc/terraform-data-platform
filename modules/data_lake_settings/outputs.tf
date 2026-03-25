output "frontend_url" {
  description = "URL pública do frontend (CloudFront)."
  value       = module.frontend_app.site_url
}

output "frontend_bucket_name" {
  description = "Nome do bucket S3 utilizado pelo frontend."
  value       = module.frontend_app.bucket_name
}

output "frontend_cloudfront_distribution_id" {
  description = "ID da distribuição CloudFront do frontend."
  value       = module.frontend_app.cloudfront_distribution_id
}

output "backend_url" {
  description = "URL pública do backend (via ALB)."
  value       = module.backend_app.url
}

output "backend_service_name" {
  description = "Nome do serviço ECS do backend."
  value       = module.backend_app.service_name
}

output "backend_task_definition_arn" {
  description = "ARN da task definition do backend."
  value       = module.backend_app.task_definition_arn
}

output "backend_ecr_repository_name" {
  description = "Nome do repositório ECR utilizado pelo backend."
  value       = module.backend_app.ecr_repository_name
}

output "backend_ecr_repository_url" {
  description = "URL do repositório ECR utilizado pelo backend."
  value       = module.backend_app.ecr_repository_url
}

output "backend_container_image" {
  description = "Imagem efetivamente utilizada pelo serviço ECS (incluindo tag)."
  value       = module.backend_app.container_image
}

output "backend_secret_name" {
  description = "Nome do secret do backend no Secrets Manager."
  value       = aws_secretsmanager_secret.backend_env.name
}

output "backend_secret_arn" {
  description = "ARN do secret do backend no Secrets Manager."
  value       = aws_secretsmanager_secret.backend_env.arn
}

output "backend_data_lake_files_policy_arn" {
  description = "ARN da policy de acesso ao bucket data-lake-files anexada ao backend."
  value       = aws_iam_policy.data_lake_files_rw.arn
}