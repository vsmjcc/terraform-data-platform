# security_groups.tf
resource "aws_security_group" "neo4j" {
  name        = "neo4j-${var.environment}-sg"
  description = "Security group for Neo4j Fargate"
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
    Name        = "neo4j-${var.environment}-sg"
    Environment = var.environment
  }
}

# Allow EFS to receive traffic from Neo4j
resource "aws_security_group_rule" "allow_neo4j_to_efs" {
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 2049
  to_port                  = 2049
  security_group_id        = aws_security_group.efs.id
  source_security_group_id = aws_security_group.neo4j.id
  description              = "Allow Neo4j to access EFS"
}

# Allow Bolt (7687)
resource "aws_security_group_rule" "allow_bolt" {
  count                    = length(var.allowed_security_groups) > 0 ? 1 : 0
  type                     = "ingress"
  from_port                = 7687
  to_port                  = 7687
  protocol                 = "tcp"
  security_group_id        = aws_security_group.neo4j.id
  source_security_group_id = var.allowed_security_groups[count.index]
}

# Allow HTTP (7474)
resource "aws_security_group_rule" "allow_http" {
  count                    = length(var.allowed_security_groups) > 0 ? 1 : 0
  type                     = "ingress"
  from_port                = 7474
  to_port                  = 7474
  protocol                 = "tcp"
  security_group_id        = aws_security_group.neo4j.id
  source_security_group_id = var.allowed_security_groups[count.index]
}