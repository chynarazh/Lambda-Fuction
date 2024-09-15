output "integration_uri" {
  value = aws_lambda_function.uchicago_lambda.invoke_arn
}

output "lambda_arn" {
  value = aws_lambda_function.uchicago_lambda.arn
}

output "lambda_name" {
  value = aws_lambda_function.uchicago_lambda.function_name
}
