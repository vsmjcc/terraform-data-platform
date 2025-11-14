resource "aws_lb" "airflow" {
  name               = "airflow-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids
}

resource "aws_lb_target_group" "airflow" {
  name        = "airflow-${var.environment}-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    port                = "8080"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 10
    matcher             = "200"
  }
}

resource "aws_lb_listener" "airflow_http" {
  load_balancer_arn = aws_lb.airflow.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "airflow_https" {
  load_balancer_arn = aws_lb.airflow.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.dns_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.airflow.arn
  }
}