resource "aws_api_gateway_rest_api" "api" {
  name        = "data-api"
  description = "API para consultar datos en Athena."
}

resource "aws_api_gateway_resource" "customers" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "customers"
}

resource "aws_api_gateway_resource" "products" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "products"
}

resource "aws_api_gateway_resource" "orders" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "orders"
}

resource "aws_api_gateway_method" "post_customers" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.customers.id
  http_method   = "POST"
  authorization = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_method" "post_products" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.products.id
  http_method   = "POST"
  authorization = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_method" "post_orders" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.orders.id
  http_method   = "POST"
  authorization = "NONE"
  api_key_required = true
}

###

resource "aws_api_gateway_api_key" "data_api_key" {
  name        = "data-api-key"
  description = "API Key for accessing the data API"
  enabled     = true
}

resource "aws_api_gateway_usage_plan" "data_usage_plan" {
  name        = "data-usage-plan"
  description = "Usage plan for the data API"
  api_stages {
    api_id = aws_api_gateway_rest_api.api.id
    stage  = aws_api_gateway_deployment.api_stage.id
  }
}

resource "aws_api_gateway_usage_plan_key" "data_usage_plan_key" {
  key_id        = aws_api_gateway_api_key.data_api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.data_usage_plan.id
}

resource "aws_api_gateway_deployment" "api_stage" {
  depends_on = [
    aws_api_gateway_method.post_customers,
    aws_api_gateway_method.post_products,
    aws_api_gateway_method.post_orders,
  ]
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "develop"
}