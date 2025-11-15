locals {
  lambda_name = "${var.name_prefix}-lambda"
  role_name   = "${var.name_prefix}-role"
  policy_name = "${var.name_prefix}-policy"
}