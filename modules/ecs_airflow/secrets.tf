resource "aws_secretsmanager_secret" "sqlalchemy_conn" {
  name = "zerezes-data-${var.environment}-AIRFLOW__DATABASE__SQL_ALCHEMY_CONN"
}

resource "aws_secretsmanager_secret_version" "sqlalchemy_conn_version" {
  secret_id     = aws_secretsmanager_secret.sqlalchemy_conn.id
  secret_string = "postgresql+psycopg2://${var.db_username}:${var.db_password}@${var.db_host}/${var.db_name}"
}