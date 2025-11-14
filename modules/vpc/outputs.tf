output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "private_subnet_cidrs" {
  value = [for subnet in aws_subnet.private : subnet.cidr_block]
}

output "private_aws_route_table_id" {
  value = aws_route_table.private.id
}

