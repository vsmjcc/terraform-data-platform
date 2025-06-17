# 🚀 Terraform Data Platform - Zerezes

Este repositório contém a infraestrutura como código (IaC) para o ambiente de dados da Zerezes (VPC, NAT Gateway, S3 Data Lake, etc).

## ✅ Pré-requisitos

### Ferramentas necessárias:

| Ferramenta | Instalação |
|---|---|
| [Terraform](https://developer.hashicorp.com/terraform/downloads) | `brew install hashicorp/tap/terraform` |
| [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) | `brew install awscli` |
| Make (já vem no macOS por padrão) | |

## ✅ Configuração do AWS CLI com SSO (IAM Identity Center)

### 1. Configurar o SSO

```bash
aws configure sso
```

**Exemplo de respostas:**

| Pergunta | Resposta |
|---|---|
| SSO session name | `zerezes-sso` |
| SSO start URL | https://d-9066398336.awsapps.com/start/ |
| SSO region | `us-east-1` |
| Account | Ex: `zerezes-data-dev (4146...)` |
| Role | `AdministratorAccess` |
| CLI profile name | Ex: `zerezes-data-dev` ou `zerezes-data-prod` |

## ✅ Estrutura de Pastas

```plaintext
infra/
├── envs/
│   ├── dev/
│   │   └── main.tfvars
│   └── prod/
│       └── main.tfvars
├── modules/
│   ├── vpc/
│   ├── nat_gateway/
│   ├── vpc_peering/
│   └── s3_data_lake/
├── main.tf
├── variables.tf
├── outputs.tf
├── backend.tf
└── Makefile
```

## ✅ Comandos Terraform usando Makefile

### Ambiente Dev

```bash
make init-dev
make plan-dev
make apply-dev
make destroy-dev
make refresh-dev
```

### Ambiente Prod

```bash
make init-prod
make plan-prod
make apply-prod
make destroy-prod
make refresh-prod
```

### Comandos Gerais

```bash
make validate
make fmt
```

## ✅ Backend Remoto (State S3 + Locking DynamoDB)

- Bucket: `terraform-state-zerezes-data`
- DynamoDB Table: `terraform-lock`
- Região: `us-east-1`

**Criação manual (exemplo):**

```bash
aws s3 mb s3://terraform-state-zerezes-data --region us-east-1 --profile zerezes-data-dev

aws dynamodb create-table \
    --table-name terraform-lock \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region us-east-1 \
    --profile zerezes-data-dev
```

## ✅ Boas práticas

- Nunca versionar arquivos `.tfstate`, `.terraform/` ou `.tfvars` com secrets.
- Versionar o `.terraform.lock.hcl` para controle de provider.
- Sempre validar (`make plan-<ambiente>`) antes de aplicar.

## ✅ Próximos passos futuros

- Criar o módulo de **VPC Peering**
- Criar recursos para **Glue**, **Athena**, **MWAA**, etc
- Implantar o ambiente **prod** após estabilizar o **dev**