provider "aws" {
        access_key = "${var.access_key}"
        secret_key = "${var.secret_key}"
        region = "${var.region}"
}

# Create archive from the code present in main.pys
data "archive_file" "string_replace_lambda" {
  type = "zip"
  source_file  = "function.py"
  output_path = "string-replace.zip"
}

# Creating s3 bucket
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "lambda-str-bucket"
  acl    = "private"
}

# Store lambda zip object in S3
resource "aws_s3_bucket_object" "string_replace_lambda_s3" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "string-replace.zip"
  source = data.archive_file.string_replace_lambda.output_path
  etag = filemd5(data.archive_file.string_replace_lambda.output_path)
}


# Creating lambda function in aws
resource "aws_lambda_function" "string_replace" {
  function_name = "StringReplace"
  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_bucket_object.string_replace_lambda_s3.key
  runtime = "python3.9"
  handler = "function.lambda_handler"
  source_code_hash = data.archive_file.string_replace_lambda.output_base64sha256
  role = aws_iam_role.lambda_exec.arn
}

# Providing minimum required access from IAM policy
resource "aws_iam_role" "lambda_exec" {
  name = "string_replace_lambda"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


resource "aws_api_gateway_rest_api" "string_replace_api_gw" {
  name = "string_relace_api"
}

resource "aws_api_gateway_resource" "replace_resource" {
  parent_id   = aws_api_gateway_rest_api.string_replace_api_gw.root_resource_id
  path_part   = "replace"
  rest_api_id = aws_api_gateway_rest_api.string_replace_api_gw.id
}

resource "aws_api_gateway_method" "post_replace" {
  resource_id   = aws_api_gateway_resource.replace_resource.id
  rest_api_id   = aws_api_gateway_rest_api.string_replace_api_gw.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integrate_function_api" {
  http_method = aws_api_gateway_method.post_replace.http_method
  resource_id = aws_api_gateway_resource.replace_resource.id
  rest_api_id = aws_api_gateway_rest_api.string_replace_api_gw.id
  uri         = "arn:aws:apigateway:ap-south-1:lambda:path/2015-03-31/functions/${aws_lambda_function.string_replace.arn}/invocations"
  type        = "AWS_PROXY"
  integration_http_method  = "POST"  #for AWs only POST method supported by Terraform
  depends_on = [
     aws_lambda_function.string_replace,
  ]
}

resource "aws_api_gateway_deployment" "replace_st" {
  rest_api_id = aws_api_gateway_rest_api.string_replace_api_gw.id
  depends_on = [
     aws_api_gateway_integration.integrate_function_api,
  ]
}

resource "aws_api_gateway_stage" "prod_stage" {
  deployment_id = aws_api_gateway_deployment.replace_st.id
  rest_api_id   = aws_api_gateway_rest_api.string_replace_api_gw.id
  stage_name    = "prod"
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.string_replace.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.string_replace_api_gw.execution_arn}/*/*"
}

output "base_url" {
  description = "Base URL for API Gateway stage."
  value = aws_api_gateway_stage.prod_stage.invoke_url
}
