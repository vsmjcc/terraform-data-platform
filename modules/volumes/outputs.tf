output "volumes" {
  description = "EFS ID e ARN dos volumes"
  value = {
    for layer, mod in local.volume_modules : layer => {
      efs_id            = mod.efs_id
      efs_arn           = mod.efs_arn
      security_group_id = mod.security_group_id
      access_point_path = mod.access_point_path
    }
  }
}
