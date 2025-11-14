output "endpoint" {
  value = aws_db_instance.this.endpoint
}

output "db_name" {
  value = var.db_name
}

output "username" {
  value = var.username
}

output "password" {
  value = random_password.rds_password.result
}

output "rds_secret_arn" {
  value = aws_secretsmanager_secret.rds_password.arn
}

output "security_group_id" {
  value = aws_security_group.rds.id
}
