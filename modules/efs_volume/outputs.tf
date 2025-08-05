output "efs_id" {
  description = "ID do EFS criado"
  value       = aws_efs_file_system.this.id
}

output "efs_arn" {
  description = "ARN do access point"
  value       = aws_efs_access_point.this.arn
}

output "security_group_id" {
  description = "ID do SG criado internamente (se aplicável)"
  value       = var.create_security_group ? aws_security_group.this[0].id : null
}

output "access_point_path" {
  description = "Path montado no access point"
  value       = var.access_point_path
}

output "access_point_id" {
  description = "Access Point ID para montagem no ECS"
  value       = aws_efs_access_point.this.id
}
