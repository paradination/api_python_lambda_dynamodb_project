resource "aws_api_gateway_rest_api" "this" {
  name        = "${local.name_prefix}-api"
  description = "REST API for clients"
}

resource "aws_api_gateway_resource" "clients" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "clients"
}

# POST /clients
resource "aws_api_gateway_method" "post_clients" {
  rest_api_id      = aws_api_gateway_rest_api.this.id
  resource_id      = aws_api_gateway_resource.clients.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = var.api_key_enabled
}

resource "aws_api_gateway_integration" "post_clients" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.clients.id
  http_method             = aws_api_gateway_method.post_clients.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.handler.invoke_arn
}

# GET /clients
resource "aws_api_gateway_method" "get_clients" {
  rest_api_id      = aws_api_gateway_rest_api.this.id
  resource_id      = aws_api_gateway_resource.clients.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = var.api_key_enabled
}

resource "aws_api_gateway_integration" "get_clients" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.clients.id
  http_method             = aws_api_gateway_method.get_clients.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.handler.invoke_arn
}

# Health
resource "aws_api_gateway_resource" "health" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "health"
}

resource "aws_api_gateway_method" "get_health" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.health.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_health" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.health.id
  http_method             = aws_api_gateway_method.get_health.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.handler.invoke_arn
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  triggers = {
    redeploy = sha1(jsonencode({
      post = aws_api_gateway_integration.post_clients.uri
      get  = aws_api_gateway_integration.get_clients.uri
      hlth = aws_api_gateway_integration.get_health.uri
    }))
  }
  lifecycle { create_before_destroy = true }
}

resource "aws_api_gateway_stage" "dev" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  deployment_id = aws_api_gateway_deployment.this.id
  stage_name    = "dev"
}

# API Key & Usage Plan (optional)
resource "aws_api_gateway_api_key" "this" {
  count   = var.api_key_enabled ? 1 : 0
  name    = "${local.name_prefix}-key"
  enabled = true
}

resource "aws_api_gateway_usage_plan" "this" {
  count = var.api_key_enabled ? 1 : 0
  name  = "${local.name_prefix}-plan"
  api_stages {
    api_id = aws_api_gateway_rest_api.this.id
    stage  = aws_api_gateway_stage.dev.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "this" {
  count         = var.api_key_enabled ? 1 : 0
  key_id        = aws_api_gateway_api_key.this[0].id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.this[0].id
}

output "api_key_value" {
  value       = var.api_key_enabled ? aws_api_gateway_api_key.this[0].value : null
  description = "Use as header x-api-key"
  sensitive   = true
}

output "api_base_url" {
  value = "https://${aws_api_gateway_rest_api.this.id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_stage.dev.stage_name}"
}
