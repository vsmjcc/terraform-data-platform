resource "aws_security_group_rule" "rds_from_app_sg" {
  provider                 = aws.peer
  count                    = var.manage_peer_side && var.peer_rds_sg_id != null && var.requester_app_sg_id != null ? 1 : 0
  type                     = "ingress"
  security_group_id        = var.peer_rds_sg_id
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  source_security_group_id = var.requester_app_sg_id
  description              = "DB access from requester app SG via VPC peering"
}

resource "aws_security_group_rule" "rds_from_requester_cidr" {
  provider          = aws.peer
  count             = var.manage_peer_side && var.peer_rds_sg_id != null && var.requester_app_sg_id == null ? 1 : 0
  type              = "ingress"
  security_group_id = var.peer_rds_sg_id
  from_port         = var.db_port
  to_port           = var.db_port
  protocol          = "tcp"
  cidr_blocks       = [var.requester_vpc_cidr]
  description       = "DB access from requester VPC CIDR via VPC peering"
}