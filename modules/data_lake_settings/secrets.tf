resource "aws_secretsmanager_secret" "backend_env" {
  name                    = "data-lake-settings-api-${var.environment}"
  description             = "Secret com variáveis sensíveis do backend data-lake-settings (${var.environment})"
  recovery_window_in_days = 7

  tags = merge(var.tags, {
    Name = "data-lake-settings-api-${var.environment}"
  })
}