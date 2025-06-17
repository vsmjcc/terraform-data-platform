resource "aws_vpc_peering_connection" "peer" {
  vpc_id        = var.requester_vpc_id
  peer_vpc_id   = var.accepter_vpc_id
  peer_owner_id = var.peer_owner_id
  peer_region   = var.peer_region
  auto_accept   = true
}

resource "aws_route" "requester_to_accepter" {
  count = length(var.requester_route_table_ids)

  route_table_id         = var.requester_route_table_ids[count.index]
  destination_cidr_block = var.accepter_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}



