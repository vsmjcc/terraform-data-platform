module "vpc" {
  source               = "./modules/vpc"
  vpc_cidr_block       = var.vpc_cidr_block
  private_subnets      = var.private_subnets
  public_subnets       = var.public_subnets
  private_azs          = var.private_azs
  public_azs           = var.public_azs
  nat_gateway_id       = module.nat_gateway.nat_gateway_id
  environment          = var.environment
  region               = var.region
  enable_vpc_flow_logs = true
}

module "nat_gateway" {
  source           = "./modules/nat_gateway"
  vpc_id           = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnet_ids[0]
}

locals {
  key_path = pathexpand("~/.ssh/aws-data-${var.environment}-key.pub")
}

variable "public_key_fallback" {
  type        = string
  description = "Opcional: cópia da chave pública para usar quando o arquivo local não existir (após criado)."
  default     = "" # preencha com a chave atual se quiser evitar ler arquivo
}

resource "aws_key_pair" "aws-data-key" {
  # endereço estável (sem count/for_each dinâmico)
  key_name = var.ssh_key_name

  # 1ª criação: precisa do arquivo; depois, se o arquivo sumir, usa o fallback.
  public_key = trimspace(try(file(local.key_path), var.public_key_fallback))

  lifecycle {
    prevent_destroy = true         # NUNCA destruir
    ignore_changes  = [public_key] # não force update se a chave mudar localmente
  }
}

module "vpn_pritunl" {
  source        = "./modules/vpn_pritunl"
  ami_id        = "ami-080e1f13689e07408"
  instance_type = "t3.micro"
  subnet_id     = module.vpc.public_subnet_ids[0]
  vpc_id        = module.vpc.vpc_id
  key_name      = var.ssh_key_name
  environment   = var.environment
}

# module "ec2_superset" {
#   source        = "./modules/ec2-superset"
#   environment   = var.environment
#   vpc_id        = module.vpc.vpc_id
#   subnet_id     = module.vpc.private_subnet_ids[0]
#   ami_id        = "ami-080e1f13689e07408"
#   instance_type = "t3.medium"
#   key_name      = var.ssh_key_name
#   enable_vpn_ssh        = true
#   vpn_security_group_id = module.vpn_pritunl.security_group_id
#   enable_alb             = true
#   alb_certificate_arn    = module.dns.dns_zones["data_zerezes"].certificate_arn
#   alb_public_subnet_ids  = module.vpc.public_subnet_ids
#   allowed_cidrs_https    = ["0.0.0.0/0"]

#   create_dns_record = true
#   dns_zone_id         = module.dns.dns_zones["data_zerezes"].zone_id
#   dns_zone_name       = module.dns.dns_zones["data_zerezes"].zone_name
# }


resource "aws_service_discovery_private_dns_namespace" "internal" {
  name        = "zerezes.local"
  description = "Internal namespace for service discovery"
  vpc         = module.vpc.vpc_id
}

module "dns" {
  source           = "./modules/dns"
  public_zone_name = var.public_zone_name
}


module "buckets" {
  source      = "./modules/buckets"
  environment = var.environment
  region      = var.region
}

module "volumes" {
  source             = "./modules/volumes"
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
}

module "lambdas" {
  source               = "./modules/lambdas"
  environment          = var.environment
  region               = var.region
  packages_bucket_name = module.buckets.packages_bucket_name
  bronze_bucket_name   = module.buckets.bronze_bucket_name
  volumes              = module.volumes.volumes
  vpc_id               = module.vpc.vpc_id
  private_subnet_ids   = module.vpc.private_subnet_ids
  dns_zones            = module.dns.dns_zones
}

module "ecs_cluster" {
  source       = "./modules/ecs_cluster"
  cluster_name = "zerezes-data"
  environment  = var.environment
}

module "ecr_repositories" {
  source = "./modules/ecr_repositories"
  repositories = [
    "airflow",
    "amundsen-frontend",
    "amundsen-metadata",
    "amundsen-search",
    "shopify-protheus-compare",
    "mocks"
  ]
}

module "rds_postgres" {
  source = "./modules/rds_postgres"

  identifier         = "zerezes-data-${var.environment}-airflow-db"
  environment        = var.environment
  db_name            = "airflow"
  username           = "airflow"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids

}

module "redis" {
  source = "./modules/redis_fargate"

  name                             = "redis-airflow"
  environment                      = var.environment
  aws_region                       = var.region
  vpc_id                           = module.vpc.vpc_id
  private_subnet_ids               = module.vpc.private_subnet_ids
  cluster_name                     = module.ecs_cluster.name
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.internal.id
  service_discovery_namespace_name = "zerezes.local"

}


module "ecs_airflow" {
  source                = "./modules/ecs_airflow"
  cluster_name          = module.ecs_cluster.name
  private_subnet_ids    = module.vpc.private_subnet_ids
  public_subnet_ids     = module.vpc.public_subnet_ids
  vpc_id                = module.vpc.vpc_id
  db_host               = module.rds_postgres.endpoint
  db_name               = module.rds_postgres.db_name
  db_username           = module.rds_postgres.username
  db_password           = module.rds_postgres.password
  environment           = var.environment
  aws_region            = var.region
  worker_count          = 1
  redis_host            = module.redis.redis_host
  ecr_repo_url          = module.ecr_repositories.repository_urls["airflow"]
  efs_id                = module.volumes.volumes["airflow_dags"].efs_id
  efs_access_point_id   = module.volumes.volumes["airflow_dags"].access_point_id
  efs_security_group_id = module.volumes.volumes["airflow_dags"].security_group_id
  dns_zone_id           = module.dns.dns_zones["data_zerezes"].zone_id
  dns_zone_name         = module.dns.dns_zones["data_zerezes"].zone_name
  dns_certificate_arn   = module.dns.dns_zones["data_zerezes"].certificate_arn
}


module "neo4j" {
  source = "./modules/ecs_neo4j"

  name               = "neo4j"
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  aws_region         = var.region
  cluster_name       = module.ecs_cluster.name
  private_subnet_ids = module.vpc.private_subnet_ids

  # # Este é o SG da sua aplicação Amundsen (Metadata/Databuilder)
  # allowed_security_groups = [module.amundsen_app.security_group_id] 

  # Vem do seu setup de Cloud Map
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.internal.id
  service_discovery_namespace_name = "zerezes.local"

}


module "elasticsearch" {
  source = "./modules/ecs_elasticsearch" # Atualize para o caminho do seu novo módulo

  # --- Variáveis de Nomenclatura e Ambiente ---
  name        = "elasticsearch" # O 'default' no variable.tf já é esse, mas é bom ser explícito
  environment = var.environment
  aws_region  = var.region

  # --- Variáveis de Rede e Cluster (iguais ao neo4j) ---
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  cluster_name       = module.ecs_cluster.name

  # --- Service Discovery (iguais ao neo4j) ---
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.internal.id
  service_discovery_namespace_name = "zerezes.local" # Mantenha o mesmo namespace

  # --- Opcionais (já têm defaults no module) ---
  # task_cpu     = 2048 # 2 vCPU
  # task_memory  = 4096 # 4 GB
  # es_java_opts = "-Xms1g -Xmx1g"
}


module "amundsen_services" {
  source = "./modules/ecs_amundsen"

  # --- Comuns ---
  environment        = var.environment
  aws_region         = var.region
  vpc_id             = module.vpc.vpc_id
  vpc_cidr_block     = var.vpc_cidr_block
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids
  cluster_name       = module.ecs_cluster.name

  # --- Service Discovery ---
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.internal.id
  service_discovery_namespace_name = "zerezes.local"

  # --- Conexão Neo4j (Vem do módulo neo4j) ---
  neo4j_host                = module.neo4j.neo4j_host
  neo4j_password_secret_arn = module.neo4j.neo4j_password_secret_arn
  neo4j_sg_id               = module.neo4j.neo4j_security_group_id

  # --- Conexão ES (Vem do módulo elasticsearch) ---
  es_host                = module.elasticsearch.elasticsearch_host
  es_password_secret_arn = module.elasticsearch.elasticsearch_password_secret_arn
  es_sg_id               = module.elasticsearch.elasticsearch_security_group_id

  # --- Configurações do Frontend ---
  # frontend_public_ip     = true # OK para teste
  frontend_allowed_cidrs = ["0.0.0.0/0"] # OK para teste

  # --- Configurações de DNS (NOVAS, vindas do seu módulo DNS) ---
  dns_zone_id         = module.dns.dns_zones["data_zerezes"].zone_id
  dns_zone_name       = module.dns.dns_zones["data_zerezes"].zone_name
  dns_certificate_arn = module.dns.dns_zones["data_zerezes"].certificate_arn

  # --- Configurações OIDC (Exemplo) ---
  # oidc_enabled        = true
  # oidc_client_id      = "meu-client-id-do-google"
  # oidc_client_secret  = "meu-client-secret"
  # oidc_discovery_url  = "https://accounts.google.com/.well-known/openid-configuration"

  image_metadata = "${module.ecr_repositories.repository_urls["amundsen-metadata"]}:latest"
  # image_search      = "${module.ecr_repositories.repository_urls["amundsen-search"]}:latest"
  image_frontend = "${module.ecr_repositories.repository_urls["amundsen-frontend"]}:latest"


}

module "shopify_protheus_compare" {
  source = "./modules/ecs_shopify_protheus_compare" # Caminho da pasta onde vc salvou os arquivos

  # --- Variáveis de Ambiente ---
  environment = var.environment
  aws_region  = var.region

  # --- Infraestrutura Base (Vem do seu módulo de VPC/Cluster existente) ---
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  cluster_name       = module.ecs_cluster.name

  # --- DNS (Vem do seu módulo de DNS) ---
  dns_zone_id         = module.dns.dns_zones["data_zerezes"].zone_id
  dns_zone_name       = module.dns.dns_zones["data_zerezes"].zone_name
  dns_certificate_arn = module.dns.dns_zones["data_zerezes"].certificate_arn

  # --- Aplicação ---
  app_name  = "shopify-protheus-compare"
  app_image = "${module.ecr_repositories.repository_urls["shopify-protheus-compare"]}:latest"
  app_port  = 8501

}

module "mocks" {
  count  = var.environment == "dev" ? 1 : 0
  source = "./modules/ecs_mocks"

  # Ambiente / Região
  environment = var.environment
  aws_region  = var.region

  # Infra base
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  cluster_name       = module.ecs_cluster.name

  # DNS (ex: mocks.data.zerezes.dev)
  dns_zone_id         = module.dns.dns_zones["data_zerezes"].zone_id
  dns_zone_name       = module.dns.dns_zones["data_zerezes"].zone_name
  dns_certificate_arn = module.dns.dns_zones["data_zerezes"].certificate_arn

  # Aplicação / Mocks
  app_name  = "mocks"
  app_image = "${module.ecr_repositories.repository_urls["mocks"]}:latest"
  app_port  = 3100

  allowed_cidrs = ["0.0.0.0/0"]

  cpu    = 256
  memory = 512
}



module "quicksight" {
  source = "./modules/quicksight"

  environment        = var.environment
  account_name       = "zerezes-bi-${var.environment}"
  notification_email = "data-notifications@zerezes.com.br"

  create_account_subscription = true
  create_account_settings     = false

  authentication_method = "IAM_IDENTITY_CENTER"
  edition               = "ENTERPRISE"

  admin_group_names  = ["aws-quicksight-${var.environment}-admins"]
  author_group_names = ["aws-quicksight-${var.environment}-authors"]
  reader_group_names = ["aws-quicksight-${var.environment}-readers"]

  # se o módulo já descobre automaticamente, pode omitir;
  # se não, passe explicitamente
  # iam_identity_center_instance_arn = var.iam_identity_center_instance_arn

  default_namespace              = "default"
  termination_protection_enabled = true

  athena_data_sources = {
    gold = {
      name           = "gold"
      data_source_id = "athena-gold"
      work_group     = "primary"
    }

  }

  create_vpc_connection = false

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "zerezes-data"
  }
}

module "quicksight_folders" {
  source = "./modules/quicksight-folders"

  environment               = var.environment
  namespace                 = "default"

  admin_group_names = [
    "aws-qs-${var.environment}-admins"
  ]

  areas = {
    marketing = {
      display_name = "Marketing"
      group_name   = "aws-qs-${var.environment}-marketing"
    }

    digital_inovacao = {
      display_name = "Digital e Inovação"
      group_name   = "aws-qs-${var.environment}-digital_inovacao"
    }

    operacoes_financeiro = {
      display_name = "Operações e Financeiro"
      group_name   = "aws-qs-${var.environment}-operacoes_financeiro"
    }

    comercial_expansao = {
      display_name = "Comercial e Expansão"
      group_name   = "aws-qs-${var.environment}-comercial_expansao"
    }

    pessoas_cultura = {
      display_name = "Pessoas e Cultura"
      group_name   = "aws-qs-${var.environment}-pessoas_cultura"
    }

    produto = {
      display_name = "Produto"
      group_name   = "aws-qs-${var.environment}-produto"
    }
  }
}

module "glue_schema" {
  source = "./modules/glue_schema"

  environment             = var.environment
  bronze_bucket           = module.buckets.bronze_bucket_name
  silver_bucket           = module.buckets.silver_bucket_name
  gold_bucket             = module.buckets.gold_bucket_name
  etls_bucket             = module.buckets.etls_bucket_name
  quicksight_data_sources = module.quicksight.quicksight_data_sources
}

module "glue_etls" {
  source = "./modules/glue_etls"

  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  bronze_bucket = module.buckets.bronze_bucket_name
  silver_bucket = module.buckets.silver_bucket_name
  gold_bucket   = module.buckets.gold_bucket_name
  etls_bucket   = module.buckets.etls_bucket_name
}


resource "aws_security_group_rule" "allow_airflow_ecs_to_redis" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  security_group_id        = module.redis.redis_security_group_id # SG do Redis
  source_security_group_id = module.ecs_airflow.airflow_sg_id     # SG do Airflow
  description              = "Permite que o ECS (Airflow) acesse o Redis."
}

module "iam" {
  source      = "./modules/iam"
  environment = var.environment
  region      = var.region
}


module "env_scheduler" {
  source = "./modules/env-scheduler"

  count = var.environment == "dev" ? 1 : 0

  name_prefix = "${var.environment}-scheduler"
  tag_key     = "Environment"
  tag_values  = [var.environment]

  # 08:00 BR = 11:00 UTC | 20:00 BR = 23:00 UTC
  start_cron_utc = "cron(0 11 ? * MON-FRI *)"
  stop_cron_utc  = "cron(0 23 ? * MON-FRI *)"

  manage_ecs = true
  manage_asg = false
  manage_ec2 = true
  manage_rds = true

  ecs_desired_default_on_start = 1
  asg_default_on_start         = { min = 1, max = 1, desired = 1 }

  tags = {
    Project     = "data-platform"
    Environment = var.environment
  }
}

module "vpc_peering" {
  source = "./modules/vpc_peering"

  # VPCs e CIDRs
  requester_vpc_id   = module.vpc.vpc_id
  requester_vpc_cidr = var.vpc_cidr_block

  peer_vpc_id     = var.peer_zerezes_vpc_id
  peer_vpc_cidr   = var.peer_zerezes_vpc_cidr
  peer_account_id = var.peer_zerezes_account_id

  # Rotas no REQUESTER (só do seu lado)
  requester_private_route_table_ids = [
    module.vpc.private_aws_route_table_id
  ]

  manage_peer_side = false

  providers = {
    aws      = aws
    aws.peer = aws.peer
  }
}


module "zextract_watermarks" {
  source = "./modules/dynamodb"

  name     = "zextract-watermarks"
  hash_key = "key"

  billing_mode = "PAY_PER_REQUEST"
  enable_pitr  = true

  tags = {
    project = "data-platform"
    env     = var.environment
  }
}



resource "aws_security_group_rule" "allow_amundsen_search_to_es" {
  # Isso é uma regra de ENTRADA (ingress)
  type = "ingress"

  # Aplica a regra no Security Group do Elasticsearch:
  security_group_id = module.elasticsearch.elasticsearch_security_group_id

  # Permite tráfego VINDO DO Security Group do Search:
  source_security_group_id = module.amundsen_services.search_security_group_id

  # Para a porta 9200
  from_port = 9200
  to_port   = 9200
  protocol  = "tcp"

  description = "Allow Amundsen Search service to access ES"
}

resource "aws_security_group_rule" "allow_metadata_to_neo4j" {
  # Isso é uma regra de ENTRADA (ingress)
  type = "ingress"

  # Aplica a regra no Security Group do Neo4j:
  security_group_id = module.neo4j.neo4j_security_group_id

  # Permite tráfego VINDO DO Security Group do Metadata:
  source_security_group_id = module.amundsen_services.metadata_security_group_id

  # Para a porta 7687 (Porta Bolt do Neo4j)
  from_port = 7687
  to_port   = 7687
  protocol  = "tcp"

  description = "Allow Amundsen Metadata service to access Neo4j"
}

resource "aws_security_group_rule" "allow_airflow_to_neo4j" {
  # Isso é uma regra de ENTRADA (ingress)
  type = "ingress"

  # Aplica a regra no Security Group do Neo4j:
  security_group_id = module.neo4j.neo4j_security_group_id

  # Permite tráfego VINDO DO Security Group do airflow:
  source_security_group_id = module.ecs_airflow.airflow_sg_id

  # Para a porta 7687 (Porta Bolt do Neo4j)
  from_port = 7687
  to_port   = 7687
  protocol  = "tcp"

  description = "Allow airflow service to access Neo4j"
}

resource "aws_security_group_rule" "allow_vpn_to_neo4j" {
  # Isso é uma regra de ENTRADA (ingress)
  type = "ingress"

  # Aplica a regra no Security Group do Neo4j:
  security_group_id = module.neo4j.neo4j_security_group_id

  # Permite tráfego VINDO DO Security Group da vpn:
  source_security_group_id = module.vpn_pritunl.security_group_id

  # Para a porta 7687 (Porta Bolt do Neo4j)
  from_port = 7687
  to_port   = 7687
  protocol  = "tcp"

  description = "Allow vpn client to access Neo4j"
}


resource "aws_security_group_rule" "allow_airflow_to_es" {
  # Isso é uma regra de ENTRADA (ingress)
  type = "ingress"

  # Aplica a regra no Security Group do Elasticsearch:
  security_group_id = module.elasticsearch.elasticsearch_security_group_id

  # Permite tráfego VINDO DO Security Group do airflow:
  source_security_group_id = module.ecs_airflow.airflow_sg_id

  # Para a porta 9200
  from_port = 9200
  to_port   = 9200
  protocol  = "tcp"

  description = "Allow Amundsen Search service to access ES"
}


resource "aws_security_group_rule" "allow_vpn_to_es" {
  # Isso é uma regra de ENTRADA (ingress)
  type = "ingress"

  # Aplica a regra no Security Group do Elasticsearch:
  security_group_id = module.elasticsearch.elasticsearch_security_group_id

  # Permite tráfego VINDO DO Security Group da VPN:
  source_security_group_id = module.vpn_pritunl.security_group_id

  # Para a porta 9200
  from_port = 9200
  to_port   = 9200
  protocol  = "tcp"

  description = "Allow VPN client to access ES"
}


resource "aws_route" "private_default_nat" {
  route_table_id         = module.vpc.private_aws_route_table_id
  destination_cidr_block = "0.0.0.0/0"

  nat_gateway_id = module.nat_gateway.nat_gateway_id
}


resource "aws_athena_workgroup" "primary" {
  name  = "primary"
  state = "ENABLED"

  configuration {
    enforce_workgroup_configuration = true

    result_configuration {
      output_location = "s3://zrzs-${var.environment}-athena-results/"
    }
  }
}


