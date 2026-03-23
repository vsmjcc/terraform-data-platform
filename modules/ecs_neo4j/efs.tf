
resource "aws_security_group" "efs" {
  name        = "neo4j-efs-${var.environment}-sg"
  description = "Security group for Neo4j EFS"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "neo4j-efs-${var.environment}-sg"
    Environment = var.environment
  }
}

resource "aws_efs_file_system" "neo4j_data" {
  creation_token = "neo4j-data-${var.environment}"
  tags = {
    Name        = "neo4j-data-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_efs_mount_target" "neo4j_data" {
  for_each = {
    for idx, subnet_id in var.private_subnet_ids :
    idx => subnet_id
  }

  file_system_id  = aws_efs_file_system.neo4j_data.id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_access_point" "neo4j_data" {
  file_system_id = aws_efs_file_system.neo4j_data.id

  root_directory {
    path = "/data"
    creation_info {
      owner_gid   = 7474
      owner_uid   = 7474
      permissions = "0755"
    }
  }

  posix_user {
    gid = 7474
    uid = 7474
  }
}