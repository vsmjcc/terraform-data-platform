
resource "aws_db_instance" "this" {
  identifier              = var.identifier
  engine                  = "postgres"
  engine_version          = "17.5"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = ["sg-04a2c216598d1a112", aws_security_group.rds.id]
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
    Name        = var.identifier
    Environment = var.environment
  }
}