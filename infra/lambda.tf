data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../app"
  output_path = local.lambda_zip
}

resource "aws_lambda_function" "handler" {
  function_name    = "${local.name_prefix}-handler"
  role             = aws_iam_role.lambda_exec.arn
  runtime          = "python3.11"
  handler          = "handler.handler"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = 10
  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.clients.name
      API_URL    = "https://*.execute-api.us-east-1.amazonaws.com/dev" #add the pull url
      X_API_KEY  = ""                                                  #replace with api key
    }
  }
  vpc_config {
    security_group_ids = [aws_security_group.lambda_vpc.id]
    subnet_ids         = [aws_subnet.public_a.id]
  }
  tags = var.tags
}
