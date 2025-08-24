resource "aws_security_group" "lambda_vpc" {
  name        = "${local.name_prefix}-lambda-sg"
  description = "Lambda SG"
  vpc_id      = aws_vpc.this.id
  tags        = merge(var.tags, { Name = "${local.name_prefix}-lambda-sg" })
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.50.0.0/16"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
