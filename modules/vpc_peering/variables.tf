variable "requester_vpc_id" {}
variable "accepter_vpc_id" {}
variable "peer_owner_id" {}
variable "peer_region" {}
variable "requester_cidr_block" {}
variable "accepter_cidr_block" {}
variable "requester_route_table_ids" {
  type = list(string)
}
