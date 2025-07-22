output "ecs_cluster_name" {
  value = module.ecs_cluster.name
}

output "rds_endpoint" {
  value = module.rds_postgres.rds_instance_endpoint
}

output "rds_secret_arn" {
  value = module.rds_postgres.rds_secret_arn
}

output "app_deploy_role_arn" {
  description = "ARN da IAM Role usada pelos pipelines de deploy das aplicações"
  value       = module.iam.app_deploy_role_arn
}

output "ecr_repository_urls" {
  value = module.ecr_repositories.repository_urls
}