variable "domain_name" {
  description = "Domínio base para o certificado (ex: data.zerezes.dev)"
  type        = string
}

variable "zone_id" {
  description = "Route 53 Zone ID do domínio"
  type        = string
}