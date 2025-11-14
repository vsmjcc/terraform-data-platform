
data "aws_subnet" "private_subnets" {
  for_each = toset(var.private_subnet_ids)
  id       = each.value
}

locals {
  private_subnet_cidrs = [for s in data.aws_subnet.private_subnets : s.cidr_block]
}