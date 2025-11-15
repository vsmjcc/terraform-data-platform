resource "aws_efs_file_system" "this" {
  creation_token = var.name

  lifecycle_policy {
    transition_to_ia = var.transition_to_ia
  }

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

resource "aws_security_group" "this" {
  count       = var.create_security_group ? 1 : 0
  name        = "${var.name}-efs-sg"
  description = "SG criado automaticamente para o volume ${var.name}"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name}-efs-sg"
  }
}

locals {
  effective_sg_ids = var.create_security_group ? [aws_security_group.this[0].id] : var.security_group_ids
}

resource "aws_efs_mount_target" "this" {
  for_each = {
    for idx, subnet_id in var.subnet_ids :
    idx => subnet_id
  }

  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = each.value
  security_groups = local.effective_sg_ids
}

resource "aws_efs_access_point" "this" {
  file_system_id = aws_efs_file_system.this.id

  root_directory {
    path = var.access_point_path
    creation_info {
      owner_uid   = var.access_point_uid
      owner_gid   = var.access_point_gid
      permissions = "0755"
    }
  }

  posix_user {
    uid = var.access_point_uid
    gid = var.access_point_gid
  }
}

