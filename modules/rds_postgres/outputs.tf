output "rds_instance_endpoint" {
  value = aws_db_instance.this.endpoint
}

output "rds_secret_arn" {
  value = aws_secretsmanager_secret.rds_password.arn
}
