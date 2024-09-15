
################# LAMBDA FUNCTION ###################
variable "lambda_name" {
  type        = string
  description = "lambda function name"
}

variable "runtime" {
  type        = string
  description = "Lambda function runtime environment"
}

variable "s3_bucket_name" {
  type        = string
  description = "S3 bucket name"
}
variable "s3_key_name" {
  type        = string
  description = "S3 bucket key name"
}
