output "endpoint" {
  value = aws_db_instance.this.endpoint
}

output "db_name" {
  value = aws_db_instance.this.db_name
}

output "username" {
  value = aws_db_instance.this.username
}

output "password" {
  value = aws_db_instance.this.password
}

output "rds_secret_arn" {
  value = aws_secretsmanager_secret.rds_password.arn
}