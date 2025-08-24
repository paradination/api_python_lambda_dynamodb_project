output "apigw_invoke_url" {
  value = aws_api_gateway_deployment.this.invoke_url
}

output "rest_api_id" {
  value = aws_api_gateway_rest_api.this.id
}

output "dynamodb_table" {
  value = aws_dynamodb_table.clients.name
}

output "lambda_name" {
  value = aws_lambda_function.handler.function_name
}
