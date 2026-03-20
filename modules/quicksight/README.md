# módulo quicksight

Módulo Terraform para preparar o ambiente básico do Amazon QuickSight com autenticação via **IAM Identity Center**.

No seu cenário, como o **Google Workspace já está integrado ao IAM Identity Center**, o módulo não configura o Google diretamente; ele apenas cria a assinatura do QuickSight usando `IAM_IDENTITY_CENTER`, que passa a reutilizar a autenticação já existente no Identity Center.

## O que este módulo cria

- `aws_quicksight_account_subscription`
- `aws_quicksight_account_settings`
- `aws_quicksight_data_source` para Athena
- `aws_quicksight_vpc_connection` opcional

## Observações importantes

1. O nome da conta QuickSight (`account_name`) precisa ser globalmente único e não pode ser alterado depois.
2. A integração com Google depende de o IAM Identity Center já estar funcionando com Google Workspace.
3. Os grupos informados em `admin_group_names`, `author_group_names` e `reader_group_names` precisam existir no IAM Identity Center.
4. O recurso `aws_quicksight_account_subscription` no provider AWS é relativamente sensível. Como proteção, o módulo usa `prevent_destroy`.

## Exemplo

```hcl
module "quicksight" {
  source = "./modules/quicksight"

  environment        = var.environment
  account_name       = "zerezes-${var.environment}-quicksight"
  notification_email = "data@zerezes.com.br"

  authentication_method = "IAM_IDENTITY_CENTER"
  edition               = "ENTERPRISE"

  admin_group_names  = ["QuickSightAdmins"]
  author_group_names = ["QuickSightAuthors"]
  reader_group_names = ["QuickSightReaders"]

  athena_data_sources = {
    primary = {
      name       = "Athena Primary"
      work_group = "primary"
    }
  }

  tags = {
    Project = "data-platform"
  }
}
```
