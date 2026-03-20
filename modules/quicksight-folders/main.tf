
data "aws_region" "current" {}
data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id

  folder_owner_actions = [
    "quicksight:CreateFolder",
    "quicksight:DescribeFolder",
    "quicksight:UpdateFolder",
    "quicksight:DeleteFolder",
    "quicksight:CreateFolderMembership",
    "quicksight:DeleteFolderMembership",
    "quicksight:DescribeFolderPermissions",
    "quicksight:UpdateFolderPermissions"
  ]

  folder_contributor_actions = [
    "quicksight:CreateFolder",
    "quicksight:DescribeFolder",
    "quicksight:CreateFolderMembership",
    "quicksight:DeleteFolderMembership",
    "quicksight:DescribeFolderPermissions"
  ]

  admin_group_arns = [
    for group_name in var.admin_group_names :
    "arn:${data.aws_partition.current.partition}:quicksight:${data.aws_region.current.name}:${local.account_id}:group/${var.namespace}/${group_name}"
  ]

  area_groups = {
    for area_key, area in var.areas :
    area_key => {
      display_name = area.display_name
      group_name   = area.group_name
      group_arn    = "arn:${data.aws_partition.current.partition}:quicksight:${data.aws_region.current.name}:${local.account_id}:group/${var.namespace}/${area.group_name}"
    }
  }
}



resource "aws_quicksight_folder" "area" {
  for_each = var.areas

  aws_account_id = local.account_id
  folder_id      = "fld-${var.environment}-${each.key}"
  name           = each.value.display_name
  # folder_type    = "RESTRICTED" 

  dynamic "permissions" {
    for_each = toset(local.admin_group_arns)
    content {
      principal = permissions.value
      actions   = local.folder_owner_actions
    }
  }

  permissions {
    principal = local.area_groups[each.key].group_arn
    actions   = local.folder_contributor_actions
  }
}