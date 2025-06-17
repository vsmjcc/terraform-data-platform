environment   = "dev"
bucket_prefix = "zerezes-data"
region        = "us-east-1"

vpc_cidr_block       = "10.30.0.0/16"
private_subnets      = ["10.30.1.0/24", "10.30.2.0/24"]
public_subnets       = ["10.30.10.0/24", "10.30.11.0/24"]
main_account_vpc_id  = "vpc-xxxxxxxxxxxx"
main_account_vpc_cidr = "10.10.0.0/16"
peer_region          = "us-east-1"
peer_owner_id        = "111111111111"

