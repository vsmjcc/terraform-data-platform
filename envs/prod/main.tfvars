environment   = "prod"
bucket_prefix = "zerezes-data"
region        = "us-east-1"

private_azs = ["us-east-1a", "us-east-1c"]
public_azs  = ["us-east-1a", "us-east-1c"]

vpc_cidr_block  = "10.31.0.0/16"
private_subnets = ["10.31.1.0/24", "10.31.2.0/24"]
public_subnets  = ["10.31.10.0/24", "10.31.11.0/24"]

peer_zerezes_vpc_id     = "vpc-08a0e8e9a408c4f7d"
peer_zerezes_vpc_cidr   = "10.25.48.0/22"
peer_zerezes_account_id = "219219235757"

ssh_key_name  = "aws-data-prod-key"

public_zone_name   = "zerezes.digital"