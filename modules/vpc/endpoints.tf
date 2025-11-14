locals {
  interface_endpoints = {
    logs           = "com.amazonaws.${var.region}.logs"
    ecr_api        = "com.amazonaws.${var.region}.ecr.api"
    ecr_dkr        = "com.amazonaws.${var.region}.ecr.dkr"
    secretsmanager = "com.amazonaws.${var.region}.secretsmanager"
  }
}

# === Security Group (mantido EXATAMENTE como está no state) ===
resource "aws_security_group" "vpc_endpoints" {
  name        = "dev-vpc-endpoints"  # ← NOME ANTIGO (não muda!)
  description = "Permite trafego interno para os endpoints"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.this.cidr_block]
    description = "HTTPS from VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dev-vpc-endpoints"
  }

  lifecycle {
    ignore_changes = [
      description,
      ingress,
      name
    ]
  }
}

# === Endpoints (só os 4, sem recriar SG) ===
resource "aws_vpc_endpoint" "interface" {
  for_each = local.interface_endpoints

  vpc_id            = aws_vpc.this.id
  service_name      = each.value
  vpc_endpoint_type = "Interface"
  subnet_ids        = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "${var.environment}-${each.key}-endpoint"
  }
}