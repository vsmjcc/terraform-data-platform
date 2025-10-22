output "instance_id" {
  value = aws_instance.this.id
}

output "private_ip" {
  value = aws_instance.this.private_ip
}

output "security_group_id" {
  value = aws_security_group.ec2.id
}

output "alb_dns_name" {
  value       = try(aws_lb.this[0].dns_name, null)
  description = "DNS público do ALB"
}


output "https_url" {
  description = "URL pública do superset com HTTPS"
  value       = "https://superset.${var.dns_zone_name}"
}

output "generated_admin_password" {
  value     = coalesce(var.superset_admin_password, try(random_password.admin[0].result, null))
  sensitive = true
}

output "generated_secret_key" {
  value     = coalesce(var.superset_secret_key, try(random_password.secret_key[0].result, null))
  sensitive = true
}



