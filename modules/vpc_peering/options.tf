resource "aws_vpc_peering_connection_options" "requester_opts" {
  count = var.manage_peer_side ? 1 : 0

  vpc_peering_connection_id = aws_vpc_peering_connection.this.id

  requester {
    allow_remote_vpc_dns_resolution = true
  }
}

resource "aws_vpc_peering_connection_options" "peer_opts" {
  provider = aws.peer
  count    = var.manage_peer_side ? 1 : 0

  vpc_peering_connection_id = aws_vpc_peering_connection.this.id

  accepter {
    allow_remote_vpc_dns_resolution = true
  }
}