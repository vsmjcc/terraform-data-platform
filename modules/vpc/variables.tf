variable "vpc_cidr_block" {}
variable "public_subnets" { type = list(string) }
variable "private_subnets" { type = list(string) }
