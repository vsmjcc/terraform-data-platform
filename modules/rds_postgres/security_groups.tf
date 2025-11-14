
resource "aws_security_group" "rds" {
  name        = "rds-${var.environment}"
  description = "Security group for RDS"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "rds-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_security_group_rule" "rds_ingress_private_subnets" {
  for_each          = toset(local.private_subnet_cidrs)
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = [each.value]
  security_group_id = aws_security_group.rds.id
  description       = "Allow PostgreSQL from subnet ${each.value}"
}