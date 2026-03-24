variable "name" {
  description = "Nome lógico da aplicação/site. Usado em nomes de recursos."
  type        = string
}

variable "environment" {
  description = "Ambiente (ex: dev, prod)."
  type        = string
}

variable "bucket_name" {
  description = "Nome do bucket S3 que armazenará os artefatos do frontend. Precisa ser globalmente único."
  type        = string
}

variable "zone_id" {
  description = "Hosted Zone ID do Route 53."
  type        = string
}

variable "zone_name" {
  description = "Nome da zona DNS, sem protocolo. Ex: zerezes.dev"
  type        = string
}

variable "subdomain" {
  description = "Subdomínio da aplicação. Ex: app. Se null ou vazio, usa o domínio raiz da zona."
  type        = string
  default     = null
}

variable "certificate_arn" {
  description = "ARN do certificado ACM em us-east-1 para o domínio configurado no CloudFront."
  type        = string
}

variable "default_root_object" {
  description = "Arquivo padrão servido na raiz."
  type        = string
  default     = "index.html"
}

variable "is_spa" {
  description = "Se true, redireciona erros 403/404 para index.html, útil para React Router."
  type        = bool
  default     = true
}

variable "enable_versioning" {
  description = "Habilita versionamento no bucket do frontend."
  type        = bool
  default     = true
}

variable "price_class" {
  description = "Price class do CloudFront."
  type        = string
  default     = "PriceClass_100"
}

variable "comment" {
  description = "Comentário opcional da distribuição CloudFront."
  type        = string
  default     = null
}

variable "wait_for_deployment" {
  description = "Se true, o Terraform espera o deploy completo do CloudFront."
  type        = bool
  default     = false
}

variable "cors_allowed_origins" {
  description = "Lista opcional de origens para CORS no bucket. Normalmente pode ficar vazia para frontend estático puro."
  type        = list(string)
  default     = []
}

variable "create_asset_cache_policy" {
  description = "Cria uma policy específica para /assets/* com TTL maior."
  type        = bool
  default     = true
}

variable "asset_cache_default_ttl" {
  description = "TTL padrão em segundos para /assets/*."
  type        = number
  default     = 86400
}

variable "asset_cache_max_ttl" {
  description = "TTL máximo em segundos para /assets/*."
  type        = number
  default     = 31536000
}

variable "tags" {
  description = "Tags adicionais."
  type        = map(string)
  default     = {}
}
