output "ecs_cluster_name" {
  value = module.ecs_cluster.name
}

output "rds_endpoint" {
  value = module.rds_postgres.endpoint
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

output "airflow_alb_dns_name" {
  description = "URL pública do Airflow Webserver"
  value       = module.ecs_airflow.airflow_alb_dns_name
}

output "redis_host" {
  description = "URL pública do Airflow Webserver"
  value       = module.redis.redis_host
}

output "private_subnet_cidrs" {
  value = module.vpc.private_subnet_cidrs
}

output "airflow_url" {
  description = "URL pública do CloudFront do airflow com HTTPS"
  value       = module.ecs_airflow.airflow_url
}

output "buckets_info" {
  description = "Nome e ARN dos buckets"
  value       = module.buckets.buckets_info
}

output "lambdas_info" {
  description = "dados das lambdas"
  value       = module.lambdas.lambdas_info
}


output "volumes_info" {
  description = "dados das lambdas"
  value       = module.volumes.volumes
}



output "data_zerezes_name_servers" {
  description = "dns name_servers"
  value       = module.dns.data_zerezes_name_servers
}


output "dns_info" {
  description = "dados dos dns"
  value       = module.dns.dns_zones
}

output "zextract_table_name" {
  value = module.zextract_watermarks.table_name
}

output "zextract_table_arn" {
  value = module.zextract_watermarks.table_arn
}



# output "superset_https_url" {
#   value       = module.ec2_superset.https_url
# }

# output "superset_generated_admin_password" {
#   value       = module.ec2_superset.generated_admin_password
#   sensitive   = true
# }

# output "superset_generated_secret_key" {
#   value       = module.ec2_superset.generated_secret_key
#   sensitive   = true
# }




