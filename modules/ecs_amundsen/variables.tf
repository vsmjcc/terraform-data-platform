# --- Variáveis Comuns de Rede e Cluster ---
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "vpc_cidr_block" {
  description = "O bloco CIDR da sua VPC (ex: 10.30.0.0/16)"
  type        = string
}

variable "private_subnet_ids" {
  description = "Lista de subnets privadas"
  type        = list(string)
}

variable "aws_region" {
  description = "Região da AWS"
  type        = string
}

variable "environment" {
  description = "Ambiente (ex: dev, staging, prod)"
  type        = string
}

variable "cluster_name" {
  description = "Nome do ECS cluster"
  type        = string
}

# --- Service Discovery ---
variable "service_discovery_namespace_id" {
  description = "ID do namespace do Cloud Map (ex: zerezes.local)"
  type        = string
}

variable "service_discovery_namespace_name" {
  description = "Ex: zerezes.local"
  type        = string
}

# --- Conexão com o Neo4j (para o Metadata) ---
variable "neo4j_host" {
  description = "DNS/Host do serviço Neo4j (ex: neo4j.zerezes.local)"
  type        = string
}
variable "neo4j_password_secret_arn" {
  description = "ARN do Secret Manager contendo a senha do Neo4j"
  type        = string
}
variable "neo4j_sg_id" {
  description = "ID do Security Group do Neo4j"
  type        = string
}

# --- Conexão com o Elasticsearch (para o Search) ---
variable "es_host" {
  description = "DNS/Host do serviço Elasticsearch (ex: elasticsearch.zerezes.local)"
  type        = string
}
variable "es_password_secret_arn" {
  description = "ARN do Secret Manager contendo a senha do ES"
  type        = string
}
variable "es_sg_id" {
  description = "ID do Security Group do ES"
  type        = string
}

# --- Configuração do Frontend ---

variable "public_subnet_ids" {
  description = "Lista de subnets públicas para o ALB do Frontend"
  type        = list(string)
}

variable "dns_zone_id" {
  description = "ID da zona hospedada no Route 53"
  type        = string
}

variable "dns_zone_name" {
  description = "Nome da zona hospedada no Route 53"
  type        = string
}

variable "dns_certificate_arn" {
  description = "ARN do certificado SSL (ACM)"
  type        = string
}

variable "frontend_allowed_cidrs" {
  description = "Lista de CIDRs que podem acessar o frontend (ex: ['0.0.0.0/0'] para público)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
variable "oidc_enabled" {
  description = "Habilita autenticação OIDC (Google, Okta, etc) no Frontend"
  type        = bool
  default     = false
}
variable "oidc_client_id" {
  description = "OIDC Client ID (se habilitado)"
  type        = string
  default     = ""
}
variable "oidc_client_secret" {
  description = "OIDC Client Secret (se habilitado)"
  type        = string
  default     = ""
  sensitive   = true
}
variable "oidc_discovery_url" {
  description = "OIDC Discovery URL (se habilitado)"
  type        = string
  default     = ""
}

# --- Imagens (com defaults) ---
variable "image_metadata" {
  type    = string
  default = "414669981241.dkr.ecr.us-east-1.amazonaws.com/amundsen-metadata:latest"
}
variable "image_search" {
  type    = string
  default = "amundsendev/amundsen-search:4.2.0"
}
variable "image_frontend" {
  type    = string
  default = "414669981241.dkr.ecr.us-east-1.amazonaws.com/amundsen-frontend:latest"
}