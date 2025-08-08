resource "aws_instance" "vpn" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.vpn.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  # protege contra terminate pela API/Console
  disable_api_termination     = true
  # opcional: evita Stop acidental (requer prov. recente)
  # disable_api_stop            = true

  # opcional: boas práticas
  monitoring = true
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"   # IMDSv2 obrigatório
  }
  root_block_device {
    encrypted   = true
    volume_size = 20
    volume_type = "gp3"
  }

  user_data = file("${path.module}/pritunl_install.sh")

  tags = {
    Name        = "vpn-pritunl-${var.environment}"
    Environment = var.environment
    Protected   = "true"
  }

    lifecycle {
    prevent_destroy = true   # protege contra terraform destroy
  }
}


resource "aws_eip" "vpn" {
  domain   = "vpc"
  instance = aws_instance.vpn.id
  tags = {
    Name        = "vpn-pritunl-${var.environment}-eip"
    Environment = var.environment
  }

  lifecycle {
    prevent_destroy = true   # protege contra terraform destroy
  }
}

resource "aws_security_group" "vpn" {
  name        = "vpn-pritunl-${var.environment}-sg"
  description = "VPN SG"
  vpc_id      = var.vpc_id

#  ingress {
#    from_port   = 22
#    to_port     = 22
#    protocol    = "tcp"
#    cidr_blocks = ["0.0.0.0/0"] # ou restringir ao seu IP
#  }

#  ingress {
#    from_port   = 443
#    to_port     = 443
#    protocol    = "tcp"
#    cidr_blocks = ["0.0.0.0/0"]
#  }

  ingress {
    from_port   = 19622
    to_port     = 19622
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpn-pritunl-${var.environment}-sg"
  }
}



