output "view_fqn" {
  value = "${var.database_name}.${var.view_name}"
}

output "quicksight_data_set_id" {
  value = try(aws_quicksight_data_set.this[0].data_set_id, null)
}

output "quicksight_data_set_arn" {
  value = try(aws_quicksight_data_set.this[0].arn, null)
}
