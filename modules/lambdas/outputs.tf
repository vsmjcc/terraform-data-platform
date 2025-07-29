output "lambdas_info" {
  description = "lambdas"
  value = {
    for layer, mod in local.lambda_modules : layer => {
      name         = mod.lambda_name
      arn          = mod.lambda_arn
      http_api_url = mod.http_api_url
    }
  }
}