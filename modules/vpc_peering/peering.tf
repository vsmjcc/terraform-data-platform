resource "aws_vpc_peering_connection" "this" {
  vpc_id        = var.requester_vpc_id
  peer_vpc_id   = var.peer_vpc_id
  peer_owner_id = var.peer_account_id
  auto_accept   = false

  tags = {
    Name = "${var.name}-requester"
  }
}

resource "aws_vpc_peering_connection_accepter" "peer_accept" {
  provider                  = aws.peer
  count                     = var.manage_peer_side ? 1 : 0
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
  auto_accept               = true

  tags = {
    Name = "${var.name}-peer"
  }
}