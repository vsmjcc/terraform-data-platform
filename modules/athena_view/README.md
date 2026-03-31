# athena_view

Cria/atualiza uma view no Athena executando `CREATE OR REPLACE VIEW` via AWS CLI.
Opcionalmente, cria também um dataset no QuickSight apontando para essa view,
com `import_mode = SPICE` ou `DIRECT_QUERY`.

## Exemplo

```hcl
module "views" {
  source = "../../../modules/athena_view"

  for_each = local.views

  region                  = var.region
  aws_account_id          = var.aws_account_id
  database_name           = var.database_name
  view_name               = each.key
  sql                     = each.value.sql
  columns                 = each.value.columns
  athena_workgroup        = var.athena_workgroup
  athena_output_location  = var.athena_output_location
  quicksight              = try(each.value.quicksight, null)
  quicksight_data_sources = var.quicksight_data_sources
}
```
