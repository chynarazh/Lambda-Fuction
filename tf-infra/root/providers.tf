provider "aws" {
  region = "us-east-1"
}
terraform {
  backend "s3" {
    bucket         = "XXXXXXXXX-state-bucket-dev"
    key            = "feature/UChicago_Lambda.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraformlock"
  }
}
