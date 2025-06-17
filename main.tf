module "vpc" {
  source          = "./modules/vpc"
  vpc_cidr_block  = var.vpc_cidr_block
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
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
