# 🚀 Terraform Data Platform - Zerezes

Este repositório contém a infraestrutura como código (IaC) para o ambiente de dados da Zerezes (VPC, NAT Gateway, etc).

## ✅ Pré-requisitos

### Ferramentas necessárias:

| Ferramenta | Instalação |
|---|---|
| [Terraform](https://developer.hashicorp.com/terraform/downloads) | Recomendado: `brew install hashicorp/tap/terraform` |
| [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) | Recomendado: `brew install awscli` |

## ✅ Configuração do AWS CLI com SSO (IAM Identity Center)

### 1. Rodar o comando de configuração SSO:

```bash
aws configure sso
```

**Exemplo de respostas:**

| Pergunta | Resposta |
|---|---|
| SSO session name | `zerezes-sso` |
| SSO start URL | https://d-9066398336.awsapps.com/start/ |
| SSO region | `us-east-1` |
| Account | Selecione: `zerezes-data-dev (4146...)` |
| Role | `AdministratorAccess` |
| CLI profile name | `zerezes-data-dev` |

## ✅ Estrutura do projeto

```plaintext
infra/
├── envs/
│   └── dev/
│       └── main.tfvars
├── modules/
│   ├── vpc/
│   ├── nat_gateway/
│   └── vpc_peering/ (em breve)
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf
└── backend.tf
```

## ✅ Configuração do backend S3 (State remoto)

- Bucket: `terraform-state-zerezes-data`
- DynamoDB Table: `terraform-lock`
- Região: `us-east-1`

**Criar manualmente antes do primeiro init:**

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

## ✅ Como executar o Terraform

Sempre usando o profile correto da conta dev:

### 1. Inicializar o projeto

```bash
AWS_PROFILE=zerezes-data-dev terraform init
```

### 2. Validar o plano de execução

```bash
AWS_PROFILE=zerezes-data-dev terraform plan -var-file=envs/dev/main.tfvars
```

### 3. Aplicar as mudanças

```bash
AWS_PROFILE=zerezes-data-dev terraform apply -var-file=envs/dev/main.tfvars
```

> ✅ Para aplicar sem confirmação manual: `-auto-approve`

## ✅ Boas práticas

- **Nunca versionar arquivos de state (`*.tfstate`) ou `.terraform/`**
- **Não subir variáveis sensíveis (`*.tfvars`)**
- **Mantenha o `.terraform.lock.hcl` versionado**
- **Sempre rodar `plan` antes de aplicar**
- **Utilizar backend remoto (S3 + DynamoDB)**

## ✅ Próximos passos futuros

- Criar módulo de **VPC Peering**
- Criar recursos para **Glue**, **Athena**, **MWAA**, etc
- Implementar ambiente **prod** quando o dev estiver estável