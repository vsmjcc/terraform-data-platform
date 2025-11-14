# instance.tf
resource "aws_instance" "vpn" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.vpn.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  disable_api_termination = true
  monitoring              = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted   = true
    volume_size = 20
    volume_type = "gp3"
  }

  user_data = templatefile("${path.module}/pritunl_install.sh", {})

  tags = merge(local.common_tags, {
    Name = "vpn-pritunl-${var.environment}"
  })

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_eip" "vpn" {
  domain   = "vpc"
  instance = aws_instance.vpn.id

  tags = merge(local.common_tags, {
    Name = "vpn-pritunl-${var.environment}-eip"
  })

  lifecycle {
    prevent_destroy = true
  }
}