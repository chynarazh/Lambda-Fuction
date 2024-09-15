terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.21.0"
    }
  }
}


module "lambda" {
  source = "../modules/lambda"

  s3_bucket_name = var.s3_bucket_name
  lambda_name    = var.lambda_name
  runtime        = var.runtime
  s3_key_name    = var.s3_key_name
}
