resource "aws_dynamodb_table" "clients" {
  name         = "${local.name_prefix}-clients"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "ClientID"

  attribute {
    name = "ClientID"
    type = "S"
  }

  tags = merge(var.tags, { Name = "${local.name_prefix}-clients" })
}
