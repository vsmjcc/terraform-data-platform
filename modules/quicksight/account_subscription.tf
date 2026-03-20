resource "aws_quicksight_account_subscription" "this" {
  count = var.create_account_subscription ? 1 : 0

  account_name          = var.account_name
  edition               = var.edition
  notification_email    = var.notification_email
  authentication_method = var.authentication_method

  iam_identity_center_instance_arn = var.authentication_method == "IAM_IDENTITY_CENTER" ? local.iam_identity_center_instance_arn : null

  admin_group  = var.admin_group_names
  author_group = var.author_group_names
  reader_group = var.reader_group_names

  lifecycle {
    prevent_destroy = true
  }
}