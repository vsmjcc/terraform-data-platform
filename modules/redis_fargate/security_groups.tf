
resource "aws_security_group" "redis" {
  name        = "redis-${var.environment}-sg"
  description = "Security group for Redis Fargate"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "redis-${var.environment}-sg"
    Environment = var.environment
  }
}

# Permite acesso ao Redis a partir dos SGs fornecidos
resource "aws_security_group_rule" "redis_ingress" {
  count                    = length(var.allowed_security_groups)
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  security_group_id        = aws_security_group.redis.id
  source_security_group_id = var.allowed_security_groups[count.index]
  description              = "Allow Redis access from application"
}