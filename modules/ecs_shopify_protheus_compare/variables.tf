# --- Identificação e Ambiente ---
variable "environment" {
  description = "Ambiente de deploy (ex: dev, prod)"
  type        = string
}

variable "aws_region" {
  description = "Região da AWS para logs e recursos"
  type        = string
  default     = "us-east-1"
}

# --- Rede (VPC e Subnets) ---
variable "vpc_id" {
  description = "ID da VPC onde os recursos serão criados"
  type        = string
}

variable "public_subnet_ids" {
  description = "Lista de IDs das subnets PÚBLICAS (para o Load Balancer)"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Lista de IDs das subnets PRIVADAS (para o Container da aplicação)"
  type        = list(string)
}

# --- Cluster ECS ---
variable "cluster_name" {
  description = "Nome do Cluster ECS existente onde o serviço vai rodar"
  type        = string
}

# --- DNS e Certificados (Route53 / ACM) ---
variable "dns_zone_id" {
  description = "ID da zona hospedada no Route 53 (ex: Z09234...)"
  type        = string
}

variable "dns_zone_name" {
  description = "Nome do domínio base (ex: data.zerezes.com.br)"
  type        = string
}

variable "dns_certificate_arn" {
  description = "ARN do certificado SSL (ACM) para HTTPS"
  type        = string
}

# --- Configuração da Aplicação ---
variable "app_image" {
  description = "URL da imagem Docker no ECR (ex: 12345.dkr.ecr.../shopify-compare:latest)"
  type        = string
}

variable "app_port" {
  description = "Porta que a aplicação Streamlit expõe (Default: 8501)"
  type        = number
  default     = 8501
}

variable "app_name" {
  description = "Nome base para os recursos (serviço, task, log group)"
  type        = string
  default     = "shopify-protheus-compare"
}

variable "allowed_cidrs" {
  description = "Lista de IPs/CIDRs permitidos no Load Balancer (ex: 0.0.0.0/0 para público)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cpu" {
  description = "CPU para a Task Fargate (256, 512, 1024...)"
  type        = number
  default     = 512
}

variable "memory" {
  description = "Memória para a Task Fargate (512, 1024, 2048...)"
  type        = number
  default     = 1024
}