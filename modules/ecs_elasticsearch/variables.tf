# Variáveis de rede (iguais ao Neo4j)
variable "vpc_id" {
  description = "VPC ID para o Elasticsearch"
  type        = string
}

variable "private_subnet_ids" {
  description = "Lista de subnets privadas para o Elasticsearch"
  type        = list(string)
}

variable "aws_region" {
  description = "Região da AWS usada para configurar o CloudWatch Logs"
  type        = string
}

# Variáveis de nomenclatura (iguais ao Neo4j)
variable "name" {
  description = "Nome base do serviço Elasticsearch"
  type        = string
  default     = "elasticsearch"
}

variable "environment" {
  description = "Ambiente (ex: dev, staging, prod)"
  type        = string
}

variable "cluster_name" {
  description = "Nome do ECS cluster"
  type        = string
}

# Variáveis de acesso (iguais ao Neo4j)
variable "allowed_security_groups" {
  description = "SGs que terão acesso ao Elasticsearch (ex: SGs das aplicações Amundsen)"
  type        = list(string)
  default     = []
}

# Variáveis de Service Discovery (iguais ao Neo4j)
variable "service_discovery_namespace_id" {
  description = "ID do namespace do Cloud Map (ex: zerezes.local)"
  type        = string
}

variable "service_discovery_namespace_name" {
  description = "Ex: zerezes.local"
  type        = string
}

# Variáveis específicas do Elasticsearch
variable "image" {
  description = "Imagem docker do Elasticsearch"
  type        = string
  default     = "docker.elastic.co/elasticsearch/elasticsearch:7.17.20"
}

variable "task_cpu" {
  description = "CPU da Task (ex: 2048 = 2 vCPU)"
  type        = number
  default     = 2048
}

variable "task_memory" {
  description = "Memória da Task (ex: 4096 = 4GB)"
  type        = number
  default     = 4096
}

variable "es_java_opts" {
  description = "Java heap size. Deve ser ~metade da memória da task."
  type        = string
  default     = "-Xms1g -Xmx1g" # 1GB de Heap para 4GB de Task
}