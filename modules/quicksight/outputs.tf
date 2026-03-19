output "aws_account_id" {
  value = local.aws_account_id
}

output "iam_identity_center_instance_arn" {
  value = local.iam_identity_center_instance_arn
}

output "quicksight_account_name" {
  value = try(aws_quicksight_account_subscription.this[0].account_name, null)
}

output "quicksight_account_edition" {
  value = try(aws_quicksight_account_subscription.this[0].edition, null)
}

output "athena_data_source_ids" {
  value = { for k, v in aws_quicksight_data_source.athena : k => v.data_source_id }
}

output "athena_data_source_arns" {
  value = { for k, v in aws_quicksight_data_source.athena : k => v.arn }
}

output "vpc_connection_arn" {
  value = try(aws_quicksight_vpc_connection.this[0].arn, null)
}