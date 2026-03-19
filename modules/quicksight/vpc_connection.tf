resource "aws_quicksight_vpc_connection" "this" {
  count = var.create_vpc_connection ? 1 : 0

  aws_account_id     = local.aws_account_id
  vpc_connection_id  = var.vpc_connection_id
  name               = coalesce(var.vpc_connection_name, var.vpc_connection_id)
  subnet_ids         = var.subnet_ids
  security_group_ids = var.security_group_ids
  role_arn           = var.role_arn

  tags = local.default_tags
}