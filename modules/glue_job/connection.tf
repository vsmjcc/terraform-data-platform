resource "aws_glue_connection" "vpc" {
  count = var.use_vpc ? 1 : 0
  name  = "glue-vpc-${var.name}"

  connection_type = "NETWORK"

  physical_connection_requirements {
    availability_zone      = data.aws_subnet.selected[0].availability_zone
    subnet_id              = var.subnet_ids[0]
    security_group_id_list = var.security_group_ids
  }

  tags = var.tags
}