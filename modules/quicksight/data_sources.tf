resource "aws_quicksight_data_source" "athena" {
  for_each = var.athena_data_sources

  aws_account_id = local.aws_account_id
  data_source_id = coalesce(try(each.value.data_source_id, null), replace(lower(each.key), "_", "-"))
  name           = each.value.name
  type           = "ATHENA"

  parameters {
    athena {
      work_group = each.value.work_group
    }
  }

  dynamic "ssl_properties" {
    for_each = each.value.ssl_properties == null ? [] : [each.value.ssl_properties]
    content {
      disable_ssl = try(ssl_properties.value.disable_ssl, false)
    }
  }

  dynamic "permission" {
    for_each = try(each.value.permissions, [])
    content {
      principal = permission.value.principal
      actions   = permission.value.actions
    }
  }
}