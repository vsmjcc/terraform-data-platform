
data "aws_subnet" "private_subnets" {
  for_each = {
    for idx, subnet_id in var.private_subnet_ids :
    idx => subnet_id
  }

  id = each.value
}

locals {
  private_subnet_cidrs = [for s in data.aws_subnet.private_subnets : s.cidr_block]
}