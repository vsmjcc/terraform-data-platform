variable "environment" {
  description = "Ambiente (dev|hom|prod...)"
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC alvo"
  type        = string
}

variable "subnet_id" {
  description = "Subnet PRIVADA onde a EC2 será criada"
  type        = string
}

variable "ami_id" {
  description = "AMI da instância (ex.: Amazon Linux 2023 x86_64)"
  type        = string
}

variable "instance_type" {
  description = "Tipo da instância EC2"
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "Nome do Key Pair para SSH (opcional)"
  type        = string
  default     = null
}

variable "root_volume_size" {
  description = "Tamanho do volume root (GB)"
  type        = number
  default     = 20
}

variable "disable_api_termination" {
  description = "Protege contra terminate via Console/API"
  type        = bool
  default     = true
}

# Segurança
variable "vpn_security_group_id" {
  description = "Security Group da VPN (apenas ele poderá acessar SSH/22 na EC2)"
  type        = string
  default     = null
}

# HTTPS/ALB
variable "enable_alb" {
  description = "Cria ALB público com HTTPS (443) e redireciona 80->443"
  type        = bool
  default     = true
}

variable "alb_certificate_arn" {
  description = "ARN do certificado ACM (wildcard) para o ALB HTTPS"
  type        = string
  default     = null
}

variable "alb_public_subnet_ids" {
  description = "Lista de Subnets PÚBLICAS para o ALB"
  type        = list(string)
  default     = []
}

variable "allowed_cidrs_https" {
  description = "CIDRs permitidos para acesso público em 443 no ALB"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# Credenciais Superset
variable "superset_admin_username" {
  description = "Usuário admin inicial do Superset"
  type        = string
  default     = "admin"
}

variable "superset_admin_password" {
  description = "Senha admin inicial (se null, será gerada)"
  type        = string
  default     = null
  sensitive   = true
}

variable "superset_admin_email" {
  description = "E-mail do admin inicial"
  type        = string
  default     = "admin@zerezes.dev"
}

variable "superset_secret_key" {
  description = "SECRET_KEY do Superset (se null, será gerada)"
  type        = string
  default     = null
  sensitive   = true
}

variable "tags" {
  description = "Tags adicionais aplicadas a todos os recursos"
  type        = map(string)
  default     = {}
}

variable "create_dns_record" {
  description = "Cria DNS no Route53"
  type        = bool
  default     = false
}

variable "dns_zone_id" {
  description = "Zone ID do Route 53"
  type        = string
  default     = null
}

variable "dns_zone_name" {
  description = "Nome da zona hospedada no Route 53"
  type        = string
  default     = null
}

variable "dns_evaluate_target_health" {
  description = "evaluate_target_health no alias"
  type        = bool
  default     = false
}

variable "enable_vpn_ssh" {
  type        = bool
  description = "Se true, cria regra de SSH 22 a partir do SG da VPN"
  default     = false
}
