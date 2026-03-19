data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_ssoadmin_instances" "this" {
  count = var.create_account_subscription && var.authentication_method == "IAM_IDENTITY_CENTER" && var.iam_identity_center_instance_arn == null ? 1 : 0
}

locals {
  aws_account_id = data.aws_caller_identity.current.account_id

  iam_identity_center_instance_arn = var.iam_identity_center_instance_arn != null ? var.iam_identity_center_instance_arn : try(data.aws_ssoadmin_instances.this[0].arns[0], null)

  default_tags = merge(
    {
      Environment = var.environment
      ManagedBy   = "terraform"
      Module      = "quicksight"
    },
    var.tags,
  )
}