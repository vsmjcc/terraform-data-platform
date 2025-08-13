module "vpc" {
  source                = "./modules/vpc"
  vpc_cidr_block        = var.vpc_cidr_block
  private_subnets       = var.private_subnets
  public_subnets        = var.public_subnets
  private_azs           = var.private_azs
  public_azs            = var.public_azs
  nat_gateway_id        = module.nat_gateway.nat_gateway_id
  environment           = var.environment
  region                = var.region
  enable_vpc_flow_logs  = true
}

module "nat_gateway" {
  source           = "./modules/nat_gateway"
  vpc_id           = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnet_ids[0]
}

resource "aws_key_pair" "aws-data-key" {
  key_name   = var.ssh_key_name
  public_key = file("~/.ssh/aws-data-${var.environment}-key.pub")
}

module "vpn_pritunl" {
  source       = "./modules/vpn_pritunl"
  ami_id       = "ami-080e1f13689e07408"
  instance_type= "t3.micro"
  subnet_id    = module.vpc.public_subnet_ids[0]
  vpc_id       = module.vpc.vpc_id
  key_name     = var.ssh_key_name
  environment  = var.environment
}


resource "aws_service_discovery_private_dns_namespace" "internal" {
  name        = "zerezes.local"
  description = "Internal namespace for service discovery"
  vpc         = module.vpc.vpc_id
}

# module "vpc_peering" {
#   source                    = "./modules/vpc_peering"
#   requester_vpc_id          = module.vpc.vpc_id
#   accepter_vpc_id           = var.main_account_vpc_id
#   peer_region               = var.peer_region
#   peer_owner_id             = var.peer_owner_id
#   requester_cidr_block      = var.vpc_cidr_block
#   accepter_cidr_block       = var.main_account_vpc_cidr
#   requester_route_table_ids = module.vpc.private_route_table_ids
# }


#module "s3_data_lake" {
#  source        = "./modules/s3_data_lake"
#  environment   = var.environment
#  bucket_prefix = var.bucket_prefix
#  region        = var.region
#}

module "dns" {
  source = "./modules/dns"
}


module "buckets" {
  source        = "./modules/buckets"
  environment   = var.environment
  region        = var.region
}

module "volumes" {
  source              = "./modules/volumes"
  environment         = var.environment
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
}

module "lambdas" {
  source              = "./modules/lambdas"
  environment         = var.environment
  region              = var.region
  packages_bucket_name= module.buckets.packages_bucket_name
  bronze_bucket_name  = module.buckets.bronze_bucket_name
  volumes             = module.volumes.volumes
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  dns_zones           = module.dns.dns_zones
}

module "ecs_cluster" {
  source       = "./modules/ecs_cluster"
  cluster_name = "zerezes-data"
  environment  = var.environment
}

module "ecr_repositories" {
  source       = "./modules/ecr_repositories"
  repositories = ["airflow"]
}

module "rds_postgres" {
  source           = "./modules/rds_postgres"
  identifier       = "zerezes-data-dev-airflow-db"
  db_name          = "airflow"
  username         = "airflow"
  vpc_id           = module.vpc.vpc_id
  subnet_ids       = module.vpc.private_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids 
}

module "redis" {
  source = "./modules/redis_fargate"

  name                = "redis-airflow"
  environment         = var.environment
  aws_region          = var.region
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  cluster_name        = module.ecs_cluster.name
  service_discovery_namespace_id = aws_service_discovery_private_dns_namespace.internal.id
  service_discovery_namespace_name = "zerezes.local"
}


module "ecs_airflow" {
  source              = "./modules/ecs_airflow"
  cluster_name        = module.ecs_cluster.name
  private_subnet_ids  = module.vpc.private_subnet_ids
  public_subnet_ids   = module.vpc.public_subnet_ids
  vpc_id              = module.vpc.vpc_id
  db_host             = module.rds_postgres.endpoint
  db_name             = module.rds_postgres.db_name
  db_username         = module.rds_postgres.username
  db_password         = module.rds_postgres.password
  environment         = var.environment
  aws_region          = var.region
  worker_count        = 1
  redis_host          = module.redis.redis_host
  ecr_repo_url        = module.ecr_repositories.repository_urls["airflow"]
  efs_id              = module.volumes.volumes["airflow_dags"].efs_id
  efs_access_point_id = module.volumes.volumes["airflow_dags"].access_point_id
  efs_security_group_id= module.volumes.volumes["airflow_dags"].security_group_id
  dns_zone_id         = module.dns.dns_zones["data_zerezes"].zone_id
  dns_zone_name       = module.dns.dns_zones["data_zerezes"].zone_name
  dns_certificate_arn = module.dns.dns_zones["data_zerezes"].certificate_arn
}


# main.tf
resource "aws_security_group" "glue" {
  name        = "glue-${var.environment}"
  description = "SG para AWS Glue"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    self            = true
    description     = "Allow Glue executors to communicate with each other"
  }
  # Se usa só endpoints VPC, mantenha egress dentro da VPC.
  # Para simplificar, liberando tudo (ajuste conforme seu padrão):
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Environment = var.environment }
}


module "glue_hello_world" {
  source = "./modules/glue_job"

  project = "zrzs-${var.environment}"
  name    = "hello-world"

  # Script no S3 (publicado pelo seu CI/CD)
  script_bucket      = "zrzs-dev-etls"
  script_key         = "glue/hello_world.py"
  upload_script      = true                         # se quiser que o TF envie a 1ª versão
  script_local_path  = "${path.root}/glue/hello_world.py"

  # TempDir
  temp_bucket = "zrzs-dev-etls"
  temp_prefix = "glue/tmp/"

  # Buckets que o job vai acessar (leitura/escrita de dados)
  data_buckets = [
    "zrzs-dev-data-lake-silver",                   # OUTPUT_PATH
    # adicione outros buckets de dados se necessário
  ]

  # Se seus buckets usam SSE-KMS, passe as chaves aqui:
  # kms_keys = ["arn:aws:kms:us-east-1:123456789012:key/...."]

  # Config do Job
  glue_version      = "4.0"
  worker_type       = "G.1X"
  number_of_workers = 2
  execution_class   = "STANDARD"

  # Args default do hello world
  default_arguments = {
    "--OUTPUT_PATH" = "s3://zrzs-dev-data-lake-silver/test/hello_world/"
  }

  # VPC interna
  use_vpc            = true
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [aws_security_group.glue.id]

  tags = {
    Project = "zrzs"
    Env     = "dev"
    Owner   = "data-platform"
  }
}

module "glue_customers_to_silver" {
  source = "./modules/glue_job"

  project = "zrzs-${var.environment}"
  name    = "shopify_customers_to_silver"

  # Script no S3 (seu CI/CD pode publicar)
  script_bucket     = "zrzs-dev-etls"
  script_key        = "glue/shopify_customers_to_silver.py"
  upload_script     = false                        # true só se quiser que TF envie o arquivo local
  script_local_path = "${path.root}/glue/shopify_customers_to_silver.py"

  # TempDir
  temp_bucket = "zrzs-dev-etls"
  temp_prefix = "glue/tmp/"

  # Buckets de dados (leitura/escrita) – bronze e silver
  data_buckets = [
    "zrzs-dev-data-lake-bronze",
    "zrzs-dev-data-lake-silver",
  ]

  # Args default do job (ajuste paths conforme sua org)
  default_arguments = {
    "--SOURCE_PATH"           = "s3://zrzs-dev-data-lake-bronze/domain=commerce/source=shopify/dataset=customers"
    "--TARGET_CUSTOMERS_PATH" = "s3://zrzs-dev-data-lake-silver/domain=commerce/source=shopify/dataset=customers"
    "--TARGET_ADDRESSES_PATH" = "s3://zrzs-dev-data-lake-silver/domain=commerce/source=shopify/dataset=customer_addresses"
    "--MODE"                  = "overwrite"
    "--SINCE_DAYS"            = "7"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-metrics"        = "true"
    "--job-bookmark-option"   = "job-bookmark-enable"
    "--conf"                  = "spark.sql.sources.partitionOverwriteMode=dynamic"
  }

  # VPC (opcional). Se não usar, deixe use_vpc = false.
  use_vpc            = true
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [aws_security_group.glue.id]

  tags = {
    Project = "zrzs"
    Env     = var.environment
    Owner   = "data-platform"
  }
}

resource "aws_glue_catalog_database" "commerce_silver" {
  name = "commerce_silver"
}

data "aws_iam_policy_document" "crawler_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "glue_crawler" {
  name               = "AWSGlueCrawlerRole-data-${var.environment}-shopify-silver"
  assume_role_policy = data.aws_iam_policy_document.crawler_trust.json
}

# S3 leitura apenas nos caminhos usados pelo crawler
data "aws_iam_policy_document" "crawler_s3_read" {
  statement {
    sid     = "ListSpecificBuckets"
    actions = ["s3:ListBucket"]
    resources = [
      "arn:aws:s3:::zrzs-dev-data-lake-silver",
    ]
    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values = [
        "domain=commerce/source=shopify/dataset=customers/*",
        "domain=commerce/source=shopify/dataset=customer_addresses/*"
      ]
    }
  }

  statement {
    sid     = "ReadObjects"
    actions = ["s3:GetObject"]
    resources = [
      "arn:aws:s3:::zrzs-dev-data-lake-silver/domain=commerce/source=shopify/dataset=customers/*",
      "arn:aws:s3:::zrzs-dev-data-lake-silver/domain=commerce/source=shopify/dataset=customer_addresses/*",
    ]
  }
}

resource "aws_iam_policy" "crawler_s3_read" {
  name   = "GlueCrawlerS3Read-data-${var.environment}-shopify-silver"
  policy = data.aws_iam_policy_document.crawler_s3_read.json
}

# Políticas: managed da AWS + S3 read acima
resource "aws_iam_role_policy_attachment" "crawler_service_managed" {
  role       = aws_iam_role.glue_crawler.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy_attachment" "crawler_s3_read_attach" {
  role       = aws_iam_role.glue_crawler.name
  policy_arn = aws_iam_policy.crawler_s3_read.arn
}


resource "aws_glue_crawler" "shopify_silver" {
  name         = "shopify-silver-crawler"
  role         = aws_iam_role.glue_crawler.arn
  database_name= aws_glue_catalog_database.commerce_silver.name
  description  = "Descobre/atualiza schemas da camada silver do Shopify (customers e addresses)"

  s3_target {
    path = "s3://zrzs-dev-data-lake-silver/domain=commerce/source=shopify/dataset=customers/"
  }

  s3_target {
    path = "s3://zrzs-dev-data-lake-silver/domain=commerce/source=shopify/dataset=customer_addresses/"
  }

  # Mantém as tabelas atualizadas no catálogo (sem apagar)
  schema_change_policy {
    update_behavior = "UPDATE_IN_DATABASE"
    delete_behavior = "LOG"
  }

  recrawl_policy {
    recrawl_behavior = "CRAWL_EVERYTHING" # ou "CRAWL_NEW_FOLDERS_ONLY"
  }

  # Se quiser rodar periodicamente, descomente e ajuste o cron:
  # schedule = "cron(0 * * * ? *)" # a cada hora
}




# resource "aws_security_group_rule" "allow_airflow_ecs_to_rds" {
#   type                     = "ingress"
#   from_port                = 5432
#   to_port                  = 5432
#   protocol                 = "tcp"
#   security_group_id        = module.rds_postgres.security_group_id       # SG do RDS
#   source_security_group_id = module.ecs_airflow.airflow_sg_id            # SG do Airflow
#   description              = "Permite que o ECS (Airflow) acesse o RDS PostgreSQL."
# }

resource "aws_security_group_rule" "allow_airflow_ecs_to_redis" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  security_group_id        = module.redis.redis_security_group_id       # SG do Redis
  source_security_group_id = module.ecs_airflow.airflow_sg_id           # SG do Airflow
  description              = "Permite que o ECS (Airflow) acesse o Redis."
}

module "iam" {
  source = "./modules/iam"
  environment         = var.environment
  region              = var.region
}


