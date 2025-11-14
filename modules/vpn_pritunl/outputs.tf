# outputs.tf
output "public_ip" {
  value       = aws_eip.vpn.public_ip
  description = "IP público (EIP) da instância Pritunl"
}

output "private_ip" {
  value       = aws_instance.vpn.private_ip
  description = "IP privado da instância"
}

output "instance_id" {
  value       = aws_instance.vpn.id
  description = "ID da instância EC2"
}

output "security_group_id" {
  value       = aws_security_group.vpn.id
  description = "ID do Security Group"
}