# Example S3 bucket (optional for artifacts)
resource "aws_s3_bucket" "artifacts" {
  bucket        = "${local.name_prefix}-artifacts-${random_string.rand.id}"
  force_destroy = true
  tags          = var.tags
}

resource "random_string" "rand" {
  length  = 6
  upper   = false
  special = false
}
