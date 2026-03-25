
resource "aws_security_group" "efs" {
  name        = "${var.name}-efs-${var.environment}-sg"
  description = "Security group for Elasticsearch EFS"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.name}-efs-${var.environment}-sg"
    Environment = var.environment
  }
}

resource "aws_efs_file_system" "es_data" {
  creation_token = "${var.name}-data-${var.environment}"
  tags = {
    Name        = "${var.name}-data-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_efs_mount_target" "es_data" {
  for_each = {
    for idx, subnet_id in var.private_subnet_ids :
    idx => subnet_id
  }

  file_system_id  = aws_efs_file_system.es_data.id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_access_point" "es_data" {
  file_system_id = aws_efs_file_system.es_data.id

  root_directory {
    path = "/usr/share/elasticsearch/data"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "0755"
    }
  }

  posix_user {
    gid = 1000
    uid = 1000
  }
}