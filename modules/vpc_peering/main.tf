terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = ">= 5.0" }
  }
}

# Providers esperados:
# - aws           -> requester (data-dev)
# - aws.peer      -> peer (zerezes) (apenas se manage_peer_side = true)

# -------------------------------
# Peering (requester side)
# -------------------------------
resource "aws_vpc_peering_connection" "this" {
  vpc_id        = var.requester_vpc_id
  peer_vpc_id   = var.peer_vpc_id
  peer_owner_id = var.peer_account_id
  auto_accept   = false

  tags = { Name = "${var.name}-requester" }
}

# -------------------------------
# Aceite no peer (opcional, gerenciado)
# -------------------------------
resource "aws_vpc_peering_connection_accepter" "peer_accept" {
  provider                  = aws.peer
  count                     = var.manage_peer_side ? 1 : 0
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
  auto_accept               = true

  tags = { Name = "${var.name}-peer" }
}

# -------------------------------
# DNS Resolution Options (ambos os lados)
# -------------------------------
resource "aws_vpc_peering_connection_options" "requester_opts" {
  count = var.manage_peer_side ? 1 : 0  # <-- acrescentar isso

  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
  requester { allow_remote_vpc_dns_resolution = true }
}

resource "aws_vpc_peering_connection_options" "peer_opts" {
  provider                  = aws.peer
  count                     = var.manage_peer_side ? 1 : 0
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id

  accepter {
    allow_remote_vpc_dns_resolution = true
  }
}

# -------------------------------
# Rotas no requester (A -> B)
# -------------------------------
resource "aws_route" "requester_routes_to_peer" {
  for_each                  = toset(var.requester_private_route_table_ids)
  route_table_id            = each.value
  destination_cidr_block    = var.peer_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}

# -------------------------------
# Rotas no peer (B -> A) (gerenciado)
# -------------------------------
resource "aws_route" "peer_routes_to_requester" {
  provider                  = aws.peer
  for_each                  = var.manage_peer_side ? toset(var.peer_private_route_table_ids) : toset([])
  route_table_id            = each.value
  destination_cidr_block    = var.requester_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}

# -------------------------------
# Regras de SG para o RDS (mesma região)
# - Se ambos SGs informados -> SG->SG
# - Senão, se só peer_rds_sg_id informado -> abre por CIDR do requester
# -------------------------------
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
