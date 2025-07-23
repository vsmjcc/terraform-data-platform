resource "random_password" "rds_password" {
  length  = 16
  special = true
  override_special = "_!#$%^&*()-"
}

resource "aws_secretsmanager_secret" "rds_password" {
  name = "zerezes-data-dev-${var.db_name}-rds-postgres"
}

resource "aws_secretsmanager_secret_version" "rds_password_version" {
  secret_id     = aws_secretsmanager_secret.rds_password.id
  secret_string = jsonencode({
    password = random_password.rds_password.result
  })
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.identifier}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.identifier}-subnet-group"
  }
}

resource "aws_db_instance" "this" {
  identifier              = var.identifier
  engine                  = "postgres"
  engine_version          = "17.5"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [var.security_group_id]
  publicly_accessible     = false
  storage_encrypted       = false
  db_name                 = var.db_name
  username                = var.username
  password                = random_password.rds_password.result
  skip_final_snapshot     = true
  deletion_protection     = false
  backup_retention_period = 1
  multi_az                = false

  tags = {
    Name = "${var.identifier}"
  }
}