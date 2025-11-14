
resource "aws_security_group" "vpn" {
  name        = "vpn-pritunl-${var.environment}-sg"
  description = "VPN SG"
  vpc_id      = var.vpc_id

  # SSH opcional (recomendo restringir!)
  # ingress {
  #   description = "SSH"
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = ["SEU_IP/32"]
  # }

  # Web UI HTTPS (opcional, se usar)
  # ingress {
  #   description = "Pritunl Web UI"
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  ingress {
    description = "WireGuard / Pritunl UDP"
    from_port   = 19622
    to_port     = 19622
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "vpn-pritunl-${var.environment}-sg"
  })
}