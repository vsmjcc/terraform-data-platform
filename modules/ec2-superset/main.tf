terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws    = { source = "hashicorp/aws",   version = ">= 5.0" }
    random = { source = "hashicorp/random", version = ">= 3.5" }
  }
}

locals {
  name = "superset-${var.environment}"
  tags = merge({
    Environment = var.environment
    Component   = "superset-ec2-docker"
  }, var.tags)
}

resource "random_password" "admin" {
  count               = var.superset_admin_password == null ? 1 : 0
  length              = 20
  special             = true
  override_special = "_!#$%^&*()-"
}

resource "random_password" "secret_key" {
  count               = var.superset_secret_key == null ? 1 : 0
  length              = 64
  special             = true
  override_special = "_!#$%^&*()-"
}

locals {
  admin_password = coalesce(var.superset_admin_password, try(random_password.admin[0].result, null))
  secret_key     = coalesce(var.superset_secret_key,   try(random_password.secret_key[0].result, null))
}

resource "aws_security_group" "ec2" {
  name        = "${local.name}-ec2-sg"
  description = "SG da EC2 ${local.name}"
  vpc_id      = var.vpc_id

  # Sem ingress inline: todas as regras de entrada são via aws_security_group_rule.

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { Name = "${local.name}-ec2-sg" })
}

resource "aws_security_group_rule" "ec2_ssh_from_vpn" {
  count                    = var.vpn_security_group_id == null ? 0 : 1
  type                     = "ingress"
  description              = "SSH 22 via VPN"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ec2.id
  source_security_group_id = var.vpn_security_group_id
}


resource "aws_instance" "this" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  associate_public_ip_address = false
  key_name                    = var.key_name

  disable_api_termination = var.disable_api_termination
  monitoring              = true
  ebs_optimized           = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    iops                  = 3000
    throughput            = 125
    delete_on_termination = true
  }

	user_data = templatefile("${path.module}/user_data.sh.tmpl", {
	  ADMIN_USERNAME       = var.superset_admin_username
	  ADMIN_PASSWORD       = local.admin_password
	  ADMIN_EMAIL          = var.superset_admin_email
	  SUPERSET_SECRET_KEY  = local.secret_key
	  REDIS_HOST           = "redis"
	  REDIS_PORT           = 6379
	  SUPERSET_DB          = "postgresql+psycopg2://superset:superset@db:5432/superset"
	})

  tags = merge(local.tags, { Name = local.name })
}

resource "aws_security_group" "alb" {
  count       = var.enable_alb ? 1 : 0
  name        = "${local.name}-alb-sg"
  description = "SG do ALB ${local.name}"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.allowed_cidrs_https
    content {
      description = "HTTPS 443"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { Name = "${local.name}-alb-sg" })
}

resource "aws_security_group_rule" "ec2_from_alb_8088" {
  count                    = var.enable_alb ? 1 : 0
  type                     = "ingress"
  description              = "Superset 8088 via ALB"
  from_port                = 8088
  to_port                  = 8088
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ec2.id
  source_security_group_id = aws_security_group.alb[0].id
}

resource "aws_lb" "this" {
  count              = var.enable_alb ? 1 : 0
  name               = "${local.name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb[0].id]
  subnets            = var.alb_public_subnet_ids
  enable_deletion_protection = false
  tags = local.tags
}

resource "aws_lb_target_group" "superset" {
  count    = var.enable_alb ? 1 : 0
  name     = "${replace(local.name, "_", "-")}-tg"
  port     = 8088
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 15
    timeout             = 5
    path                = "/login/"
    matcher             = "200-399"
  }
  tags = local.tags
}

resource "aws_lb_target_group_attachment" "ec2" {
  count            = var.enable_alb ? 1 : 0
  target_group_arn = aws_lb_target_group.superset[0].arn
  target_id        = aws_instance.this.id
  port             = 8088
}

resource "aws_lb_listener" "https" {
  count             = var.enable_alb ? 1 : 0
  load_balancer_arn = aws_lb.this[0].arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-3-2021-06"
  certificate_arn   = var.alb_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.superset[0].arn
  }
}

resource "aws_route53_record" "superset_dns" {
  zone_id = var.dns_zone_id
  name    = "superset.${var.dns_zone_name}"
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.this[0].dns_name]
}
