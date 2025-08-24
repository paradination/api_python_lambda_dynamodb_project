terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws     = { source = "hashicorp/aws", version = "~> 5.50" }
    archive = { source = "hashicorp/archive", version = "~> 2.4" }
    random  = { source = "hashicorp/random", version = "~> 3.6" }
  }
}

provider "aws" {
  region = var.region
}

# Backend state config (optional)
# terraform {
#   backend "s3" {
#     bucket = "YOUR_TF_STATE_BUCKET"
#     key    = "allstate-cyber-recovery-sre-lab/terraform.tfstate"
#     region = "us-east-1"
#   }
# }

locals {
  name_prefix = "${var.project}-${var.env}"
  lambda_zip  = "${path.module}/../build/lambda.zip"
}
