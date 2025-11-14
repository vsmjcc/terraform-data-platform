
# Rotas no requester (sempre criadas)
resource "aws_route" "requester_to_peer" {
  count                     = length(var.requester_private_route_table_ids)
  route_table_id            = var.requester_private_route_table_ids[count.index]
  destination_cidr_block    = var.peer_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}

# Rotas no peer (apenas se manage_peer_side = true)
resource "aws_route" "peer_to_requester" {
  provider                  = aws.peer
  count                     = var.manage_peer_side ? length(var.peer_private_route_table_ids) : 0
  route_table_id            = var.peer_private_route_table_ids[count.index]
  destination_cidr_block    = var.requester_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}