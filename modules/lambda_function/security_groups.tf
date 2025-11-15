resource "aws_security_group" "lambda" {
  count = length(var.subnet_ids) > 0 && length(var.security_group_ids) == 0 ? 1 : 0

  name        = "${var.function_name}-sg"
  description = "Security group for Lambda function ${var.function_name}"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.function_name}-sg"
  }
}

resource "aws_security_group_rule" "allow_lambda_to_efs" {
  count = var.allow_efs_ingress ? 1 : 0

  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id        = var.efs_security_group_id
  source_security_group_id = aws_security_group.lambda[0].id
  description              = "Permite que a Lambda acesse o EFS via NFS"
}