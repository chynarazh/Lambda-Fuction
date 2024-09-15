
############### S3 bucket to store Lambda function code ###############
resource "aws_s3_bucket" "lambda_code_bucket" {
  bucket = var.s3_bucket_name
}

############### Upload Lambda function code to S3 ###############
resource "aws_s3_bucket_object" "lambda_zip" {
  bucket = aws_s3_bucket.lambda_code_bucket.id
  key    = "uchicago_lambda.zip"
  source = "../../backend/uchicago_lambda.zip"
}

############### Archive Lambda code as a ZIP file ###############
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "../../backend/uchicago_lambda.py/"
  output_path = "../../backend/uchicago_lambda.zip"
}

############### LAMBDA FUNCTION #######################
resource "aws_lambda_function" "uchicago_lambda" {
  function_name = var.lambda_name
  s3_bucket     = var.s3_bucket_name
  s3_key        = aws_s3_bucket_object.lambda_zip.key
  runtime       = var.runtime
  handler       = "uchicago_lambda.handler"

  role             = aws_iam_role.lambda_exec.arn
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      greeting = "Hello UChicago"
    }
  }
}

############### IAM Role for Lambda ####################
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

############### Attach AWSLambdaBasicExecutionRole policy to Lambda ####################
resource "aws_iam_role_policy_attachment" "AWSLambdaBasicExecutionRole_to_lambda_exec" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_exec.name
}

############### S3 Bucket Policy for Lambda Access ####################
data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    sid = "1"
    actions = [
      "s3:GetObject", "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::${var.s3_bucket_name}/*"
    ]
  }
}

resource "aws_iam_policy" "s3_bucket_policy" {
  name   = "s3_bucket_policy"
  policy = data.aws_iam_policy_document.s3_bucket_policy.json
}

resource "aws_iam_role_policy_attachment" "s3_bucket_policy_attachment" {
  policy_arn = aws_iam_policy.s3_bucket_policy.arn
  role       = aws_iam_role.lambda_exec.name
}

############### CloudWatch Event Rule to trigger Lambda every 5 minutes ####################
resource "aws_cloudwatch_event_rule" "every_five_minutes" {
  name                = "every_five_minutes"
  description         = "Triggers Lambda function every 5 minutes"
  schedule_expression = "cron(*/5 * * * ? *)"
}

############### CloudWatch Event Target for Lambda Trigger ####################
resource "aws_cloudwatch_event_target" "lambda_trigger" {
  rule      = aws_cloudwatch_event_rule.every_five_minutes.name
  target_id = "lambda"
  arn       = aws_lambda_function.uchicago_lambda.arn
}

############### Grant CloudWatch Permission to Invoke Lambda ####################
resource "aws_lambda_permission" "allow_cloudwatch_to_invoke_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.uchicago_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_five_minutes.arn
}
