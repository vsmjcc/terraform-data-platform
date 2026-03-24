
resource "aws_iam_role_policy_attachment" "attach_s3_dag_upload_policy" {
  role       = aws_iam_role.app_deploy_role.name
  policy_arn = aws_iam_policy.s3_dag_upload_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_s3_etls_glue_upload_policy" {
  role       = aws_iam_role.app_deploy_role.name
  policy_arn = aws_iam_policy.s3_etls_glue_upload_policy.arn
}

resource "aws_iam_role_policy_attachment" "ecs_deploy_access" {
  role       = aws_iam_role.app_deploy_role.name
  policy_arn = aws_iam_policy.ecs_deploy_policy.arn
}

resource "aws_iam_role_policy_attachment" "ecr_access" {
  role       = aws_iam_role.app_deploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_role_policy_attachment" "secretsmanager_access" {
  role       = aws_iam_role.app_deploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_iam_role_policy_attachment" "ssm_access" {
  role       = aws_iam_role.app_deploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_deploy_attach" {
  role       = aws_iam_role.app_deploy_role.name
  policy_arn = aws_iam_policy.lambda_deploy_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_bronze_write_to_lambda" {
  role       = "ingest-typeform-to-bronze-lambda-role"
  policy_arn = aws_iam_policy.bronze_write_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_shopify_orders_bronze_write_to_lambda" {
  role       = "ingest-shopify-orders-to-bronze-lambda-role"
  policy_arn = aws_iam_policy.bronze_write_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_shopify_products_bronze_write_to_lambda" {
  role       = "ingest-shopify-products-to-bronze-lambda-role"
  policy_arn = aws_iam_policy.bronze_write_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_shopify_customers_bronze_write_to_lambda" {
  role       = "ingest-shopify-customers-to-bronze-lambda-role"
  policy_arn = aws_iam_policy.bronze_write_policy.arn
}

resource "aws_iam_role_policy_attachment" "app_deploy_s3_frontend" {
  role       = aws_iam_role.app_deploy_role.name
  policy_arn = aws_iam_policy.s3_frontend_deploy_policy.arn
}

resource "aws_iam_role_policy_attachment" "app_deploy_cloudfront" {
  role       = aws_iam_role.app_deploy_role.name
  policy_arn = aws_iam_policy.cloudfront_invalidation_policy.arn
}