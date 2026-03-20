resource "aws_quicksight_account_settings" "this" {
  count = var.create_account_settings ? 1 : 0

  aws_account_id                 = local.aws_account_id
  default_namespace              = var.default_namespace
  termination_protection_enabled = var.termination_protection_enabled
}