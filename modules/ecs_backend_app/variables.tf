variable "name" {
  description = "Nome base da aplicação."
  type        = string
}

variable "environment" {
  description = "Ambiente da aplicação (ex: dev, prod)."
  type        = string
}

variable "aws_region" {
  description = "Região AWS onde os recursos serão provisionados."
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC onde o serviço será criado."
  type        = string
}

variable "private_subnet_ids" {
  description = "Lista de subnets privadas para execução das tasks ECS."
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "Lista de subnets públicas para o Application Load Balancer."
  type        = list(string)
}

variable "container_image" {
  description = "Imagem completa do container. Quando nula, o módulo usa o repositório ECR criado internamente com a tag definida em image_tag."
  type        = string
  default     = null
}

variable "image_tag" {
  description = "Tag da imagem usada quando container_image não for informado."
  type        = string
  default     = "latest"
}

variable "create_ecr_repository" {
  description = "Define se o módulo deve criar um repositório ECR para a aplicação."
  type        = bool
  default     = true
}

variable "ecr_repository_name" {
  description = "Nome do repositório ECR. Quando nulo, será usado o nome base da aplicação."
  type        = string
  default     = null
}

variable "ecr_image_tag_mutability" {
  description = "Define se as tags do ECR podem ser sobrescritas."
  type        = string
  default     = "MUTABLE"
}

variable "ecr_force_delete" {
  description = "Permite remover o repositório ECR mesmo contendo imagens."
  type        = bool
  default     = false
}

variable "container_port" {
  description = "Porta exposta pelo container."
  type        = number
  default     = 8000
}

variable "cpu" {
  description = "Quantidade de CPU da task ECS."
  type        = number
  default     = 512
}

variable "memory" {
  description = "Quantidade de memória da task ECS em MB."
  type        = number
  default     = 1024
}

variable "desired_count" {
  description = "Quantidade desejada de instâncias do serviço ECS."
  type        = number
  default     = 1
}

variable "health_check_path" {
  description = "Endpoint utilizado para health check do backend."
  type        = string
  default     = "/health"
}

variable "environment_variables" {
  description = "Variáveis de ambiente do container no formato chave => valor."
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Secrets do container no formato nome => ARN."
  type        = map(string)
  default     = {}
}

variable "dns_zone_id" {
  description = "ID da Hosted Zone no Route 53."
  type        = string
}

variable "dns_zone_name" {
  description = "Nome da zona DNS (ex: data.zerezes.dev)."
  type        = string
}

variable "cluster_name" {
  description = "Nome do cluster ECS onde o serviço será criado."
  type        = string
}

variable "subdomain" {
  description = "Subdomínio da aplicação."
  type        = string
}

variable "dns_certificate_arn" {
  description = "ARN do certificado ACM utilizado no listener HTTPS do ALB."
  type        = string
}

variable "tags" {
  description = "Tags aplicadas aos recursos AWS."
  type        = map(string)
  default     = {}
}

variable "secret_arns_for_execution_role" {
  description = "Lista de ARNs de secrets que a execution role da task pode ler."
  type        = list(string)
  default     = []
}

variable "task_role_policy_arns" {
  description = "Lista de policy ARNs para anexar na task role."
  type        = list(string)
  default     = []
}