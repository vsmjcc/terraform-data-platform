variable "vpc_cidr_block" {}
variable "private_subnets" { type = list(string) }
variable "public_subnets" { type = list(string) }
variable "main_account_vpc_id" {}
variable "main_account_vpc_cidr" {}
variable "peer_region" {}
variable "peer_owner_id" {}
