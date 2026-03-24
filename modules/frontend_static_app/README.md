# frontend_static_site

Módulo Terraform genérico para publicar frontend React estático usando:

- S3 privado
- CloudFront com OAC
- Route 53
- ACM

## Uso

```hcl
module "frontend_app" {
  source = "./modules/frontend_static_site"

  name            = "data-lake-config"
  environment     = var.environment
  bucket_name     = "zrzs-${var.environment}-data-lake-config-frontend"
  zone_id         = module.dns.zone_id
  zone_name       = "data.zerezes.dev"
  subdomain       = "config"
  certificate_arn = module.acm_us_east_1.certificate_arn

  is_spa               = true
  enable_versioning    = true
  wait_for_deployment  = false
  price_class          = "PriceClass_100"

  tags = {
    Project     = "zerezes-data"
    ManagedBy   = "terraform"
    Environment = var.environment
  }
}
```

## Observações

- O certificado ACM precisa estar em **us-east-1**, porque o CloudFront exige isso.
- Para React Router, mantenha `is_spa = true`.
- O deploy dos arquivos (`npm run build` + sync para S3 + invalidation do CloudFront) pode ser feito depois via GitHub Actions.
