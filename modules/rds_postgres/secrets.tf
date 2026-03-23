
resource "random_password" "rds_password" {
  length           = 16
  special          = true
  override_special = "_!#$%^&*()-"
}

resource "aws_secretsmanager_secret" "rds_password" {
  name = "zerezes-data-${var.environment}-${var.db_name}-rds-postgres"
}

resource "aws_secretsmanager_secret_version" "rds_password_version" {
  secret_id = aws_secretsmanager_secret.rds_password.id
  secret_string = jsonencode({
    password = random_password.rds_password.result
  })
}