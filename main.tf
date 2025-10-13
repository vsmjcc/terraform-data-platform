module "vpc" {
  source                = "./modules/vpc"
  vpc_cidr_block        = var.vpc_cidr_block
  private_subnets       = var.private_subnets
  public_subnets        = var.public_subnets
  private_azs           = var.private_azs
  public_azs            = var.public_azs
  nat_gateway_id        = module.nat_gateway.nat_gateway_id
  environment           = var.environment
  region                = var.region
  enable_vpc_flow_logs  = true
}

module "nat_gateway" {
  source           = "./modules/nat_gateway"
  vpc_id           = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnet_ids[0]
}

locals {
  key_path = pathexpand("~/.ssh/aws-data-${var.environment}-key.pub")
}

variable "public_key_fallback" {
  type        = string
  description = "Opcional: cópia da chave pública para usar quando o arquivo local não existir (após criado)."
  default     = "" # preencha com a chave atual se quiser evitar ler arquivo
}

resource "aws_key_pair" "aws_data_key" {
  # endereço estável (sem count/for_each dinâmico)
  key_name   = var.ssh_key_name

  # 1ª criação: precisa do arquivo; depois, se o arquivo sumir, usa o fallback.
  public_key = trimspace(try(file(local.key_path), var.public_key_fallback))

  lifecycle {
    prevent_destroy = true         # NUNCA destruir
    ignore_changes  = [public_key] # não force update se a chave mudar localmente
  }
}

module "vpn_pritunl" {
  source       = "./modules/vpn_pritunl"
  ami_id       = "ami-080e1f13689e07408"
  instance_type= "t3.micro"
  subnet_id    = module.vpc.public_subnet_ids[0]
  vpc_id       = module.vpc.vpc_id
  key_name     = var.ssh_key_name
  environment  = var.environment
}


resource "aws_service_discovery_private_dns_namespace" "internal" {
  name        = "zerezes.local"
  description = "Internal namespace for service discovery"
  vpc         = module.vpc.vpc_id
}

# module "vpc_peering" {
#   source                    = "./modules/vpc_peering"
#   requester_vpc_id          = module.vpc.vpc_id
#   accepter_vpc_id           = var.main_account_vpc_id
#   peer_region               = var.peer_region
#   peer_owner_id             = var.peer_owner_id
#   requester_cidr_block      = var.vpc_cidr_block
#   accepter_cidr_block       = var.main_account_vpc_cidr
#   requester_route_table_ids = module.vpc.private_route_table_ids
# }


#module "s3_data_lake" {
#  source        = "./modules/s3_data_lake"
#  environment   = var.environment
#  bucket_prefix = var.bucket_prefix
#  region        = var.region
#}

module "dns" {
  source = "./modules/dns"
}


module "buckets" {
  source        = "./modules/buckets"
  environment   = var.environment
  region        = var.region
}

module "volumes" {
  source              = "./modules/volumes"
  environment         = var.environment
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
}

module "lambdas" {
  source              = "./modules/lambdas"
  environment         = var.environment
  region              = var.region
  packages_bucket_name= module.buckets.packages_bucket_name
  bronze_bucket_name  = module.buckets.bronze_bucket_name
  volumes             = module.volumes.volumes
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  dns_zones           = module.dns.dns_zones
}

module "ecs_cluster" {
  source       = "./modules/ecs_cluster"
  cluster_name = "zerezes-data"
  environment  = var.environment
}

module "ecr_repositories" {
  source       = "./modules/ecr_repositories"
  repositories = ["airflow"]
}

module "rds_postgres" {
  source           = "./modules/rds_postgres"

  identifier       = "zerezes-data-dev-airflow-db"
  environment         = var.environment
  db_name          = "airflow"
  username         = "airflow"
  vpc_id           = module.vpc.vpc_id
  subnet_ids       = module.vpc.private_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids 

}

module "redis" {
  source = "./modules/redis_fargate"

  name                = "redis-airflow"
  environment         = var.environment
  aws_region          = var.region
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  cluster_name        = module.ecs_cluster.name
  service_discovery_namespace_id = aws_service_discovery_private_dns_namespace.internal.id
  service_discovery_namespace_name = "zerezes.local"

}


module "ecs_airflow" {
  source              = "./modules/ecs_airflow"
  cluster_name        = module.ecs_cluster.name
  private_subnet_ids  = module.vpc.private_subnet_ids
  public_subnet_ids   = module.vpc.public_subnet_ids
  vpc_id              = module.vpc.vpc_id
  db_host             = module.rds_postgres.endpoint
  db_name             = module.rds_postgres.db_name
  db_username         = module.rds_postgres.username
  db_password         = module.rds_postgres.password
  environment         = var.environment
  aws_region          = var.region
  worker_count        = 1
  redis_host          = module.redis.redis_host
  ecr_repo_url        = module.ecr_repositories.repository_urls["airflow"]
  efs_id              = module.volumes.volumes["airflow_dags"].efs_id
  efs_access_point_id = module.volumes.volumes["airflow_dags"].access_point_id
  efs_security_group_id= module.volumes.volumes["airflow_dags"].security_group_id
  dns_zone_id         = module.dns.dns_zones["data_zerezes"].zone_id
  dns_zone_name       = module.dns.dns_zones["data_zerezes"].zone_name
  dns_certificate_arn = module.dns.dns_zones["data_zerezes"].certificate_arn
}


module "glue_etls" {
  source = "./modules/glue_etls"

  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  bronze_bucket      = module.buckets.bronze_bucket_name
  silver_bucket      = module.buckets.silver_bucket_name
  gold_bucket        = module.buckets.gold_bucket_name
  etls_bucket        = module.buckets.etls_bucket_name
}


resource "aws_security_group_rule" "allow_airflow_ecs_to_redis" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  security_group_id        = module.redis.redis_security_group_id       # SG do Redis
  source_security_group_id = module.ecs_airflow.airflow_sg_id           # SG do Airflow
  description              = "Permite que o ECS (Airflow) acesse o Redis."
}

module "iam" {
  source = "./modules/iam"
  environment         = var.environment
  region              = var.region
}


module "env_scheduler" {
  source = "./modules/env-scheduler"

  name_prefix   = "dev-scheduler"
  tag_key       = "Environment"
  tag_values    = ["dev"]

  # 08:00 BR = 11:00 UTC | 20:00 BR = 23:00 UTC
  start_cron_utc = "cron(0 11 ? * MON-FRI *)"
  stop_cron_utc  = "cron(0 23 ? * MON-FRI *)"

  manage_ecs = true
  manage_asg = false
  manage_ec2 = true
  manage_rds = true

  ecs_desired_default_on_start = 1
  asg_default_on_start = { min = 1, max = 1, desired = 1 }

  tags = {
    Project     = "data-platform"
    Environment = "dev"
  }
}



