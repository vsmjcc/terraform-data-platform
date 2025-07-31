module "vpc" {
  source          = "./modules/vpc"
  vpc_cidr_block  = var.vpc_cidr_block
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  private_azs     = var.private_azs
  public_azs      = var.public_azs
  nat_gateway_id  = module.nat_gateway.nat_gateway_id
  environment     = var.environment
}

module "nat_gateway" {
  source           = "./modules/nat_gateway"
  vpc_id           = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnet_ids[0]
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


module "buckets" {
  source        = "./modules/buckets"
  environment   = var.environment
  region        = var.region
}

module "lambdas" {
  source              = "./modules/lambdas"
  environment         = var.environment
  region              = var.region
  packages_bucket_name= module.buckets.packages_bucket_name
  bronze_bucket_name  = module.buckets.bronze_bucket_name
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
}

# resource "aws_security_group_rule" "allow_airflow_ecs_to_rds" {
#   type                     = "ingress"
#   from_port                = 5432
#   to_port                  = 5432
#   protocol                 = "tcp"
#   security_group_id        = module.rds_postgres.security_group_id       # SG do RDS
#   source_security_group_id = module.ecs_airflow.airflow_sg_id            # SG do Airflow
#   description              = "Permite que o ECS (Airflow) acesse o RDS PostgreSQL."
# }

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


