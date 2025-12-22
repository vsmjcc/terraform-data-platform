# --- Identificação e Ambiente ---
variable "environment" {
  description = "Ambiente de deploy (ex: dev, prod)"
  type        = string
}

variable "aws_region" {
  description = "Região da AWS"
  type        = string
  default     = "us-east-1"
}

# app_name = prefixo de nomes (ALB, service, log group, DNS)
# Para o caso dos mocks, use "mocks"
variable "app_name" {
  description = "Nome base para os recursos (service, ALB, logs, DNS)"
  type        = string
  default     = "mocks"
}

# --- Rede ---
variable "vpc_id" {
  description = "ID da VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "Subnets públicas (ALB)"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Subnets privadas (ECS Tasks)"
  type        = list(string)
}

# --- Cluster ECS ---
variable "cluster_name" {
  description = "Nome do cluster ECS"
  type        = string
}

# --- DNS / Certificado ---
variable "dns_zone_id" {
  description = "ID da zona no Route53"
  type        = string
}

variable "dns_zone_name" {
  description = "Nome do domínio base (ex: data.zerezes.dev)"
  type        = string
}

variable "dns_certificate_arn" {
  description = "ARN do certificado ACM para HTTPS"
  type        = string
}

# --- Aplicação / Container ---
variable "app_image" {
  description = "Imagem Docker no ECR"
  type        = string
}

variable "app_port" {
  description = "Porta exposta pelo container"
  type        = number
  default     = 3100
}

variable "health_check_path" {
  description = "Path do health check do ALB"
  type        = string
  default     = "/"
}

# Env vars simples (sem Secrets Manager)
variable "app_environment" {
  description = "Lista de variáveis de ambiente para o container"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

# --- Acesso externo ao ALB ---
variable "allowed_cidrs" {
  description = "CIDRs permitidos no ALB (HTTPS)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# --- Tamanho da task ---
variable "cpu" {
  description = "CPU Fargate (256, 512, 1024...)"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Memória Fargate (512, 1024, 2048...)"
  type        = number
  default     = 512
}
