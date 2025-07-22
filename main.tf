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



module "bronze_bucket" {
  source        = "./modules/data_lake_bucket"
  environment   = var.environment
  bucket_prefix = var.bucket_prefix
  layer         = "bronze"
}

module "silver_bucket" {
  source        = "./modules/data_lake_bucket"
  environment   = var.environment
  bucket_prefix = var.bucket_prefix
  layer         = "silver"
}

module "gold_bucket" {
  source        = "./modules/data_lake_bucket"
  environment   = var.environment
  bucket_prefix = var.bucket_prefix
  layer         = "gold"
}

module "ecs_cluster" {
  source       = "./modules/ecs_cluster"
  cluster_name = "zerezes-data"
  environment  = var.environment
}

module "rds_postgres" {
  source           = "./modules/rds_postgres"
  identifier       = "zerezes-data-dev-airflow-db"
  username         = "airflow"
  subnet_ids       = module.vpc.private_subnet_ids
  security_group_id = aws_security_group.airflow.id
}

module "ecs_airflow" {
  source            = "./modules/ecs_airflow"
  cluster_name      = module.ecs_cluster.name
  subnet_ids        = module.vpc.private_subnet_ids
  security_group_id = aws_security_group.airflow.id

  rds_endpoint      = module.rds_postgres.rds_instance_endpoint
  rds_secret_arn    = module.rds_postgres.rds_secret_arn
  environment       = var.environment
  region            = var.region
}


module "iam" {
  source = "./modules/iam"
}

module "ecr_repositories" {
  source       = "./modules/ecr_repositories"
  repositories = ["airflow"]
}