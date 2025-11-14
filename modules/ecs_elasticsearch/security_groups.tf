
resource "aws_security_group" "elasticsearch" {
  name        = "${var.name}-${var.environment}-sg"
  description = "Security group for Elasticsearch Fargate"
  vpc_id      = var.vpc_id

  egress {
    protocol        = "tcp"
    from_port       = 2049
    to_port         = 2049
    security_groups = [aws_security_group.efs.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${var.name}-${var.environment}-sg"
    Environment = var.environment
  }
}

# Allow EFS to receive traffic from ES
resource "aws_security_group_rule" "allow_es_to_efs" {
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 2049
  to_port                  = 2049
  security_group_id        = aws_security_group.efs.id
  source_security_group_id = aws_security_group.elasticsearch.id
  description              = "Allow Elasticsearch to access EFS"
}

# Allow external apps (Amundsen, etc.)
resource "aws_security_group_rule" "allow_api_access" {
  count                    = length(var.allowed_security_groups) > 0 ? 1 : 0
  type                     = "ingress"
  from_port                = 9200
  to_port                  = 9200
  protocol                 = "tcp"
  security_group_id        = aws_security_group.elasticsearch.id
  source_security_group_id = var.allowed_security_groups[count.index]
}