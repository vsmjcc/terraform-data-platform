output "expected_area_groups" {
  value = {
    for k, v in local.area_groups : k => v.group_name
  }
}

output "area_folder_arns" {
  value = {
    for k, v in aws_quicksight_folder.area : k => v.arn
  }
}