terraform {
  backend "s3" {}
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.19.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.3.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
  }

  required_version = "~> 1.0"
}


provider "aws" {
  region = var.aws_region
}

###########################################################################################################
# DYNAMODB 
###########################################################################################################

resource "aws_dynamodb_table" "dynamodb_table" {
  name           = var.table_name
  billing_mode   = "PROVISIONED"
  read_capacity  = 2
  write_capacity = 1
  hash_key       = "prefix"


  attribute {
    name = "prefix"
    type = "S"
  }

  tags = {
    Name        = "${var.table_name}"
    Environment = "${var.environment}"
  }
}

###########################################################################################################
# S3 
###########################################################################################################

resource "aws_s3_bucket" "lambda_bucket" {
  bucket        = var.lambda_bucket_name
  acl           = "private"
  force_destroy = true

  tags = {
    Environment = "${var.environment}"
  }
}


###########################################################################################################
# LAMBDA
###########################################################################################################

resource "aws_lambda_function" "lambda_function" {
  function_name = "${var.project_label}-lambda-function"
  s3_bucket     = aws_s3_bucket.lambda_bucket.id
  s3_key        = aws_s3_bucket_object.lambda_s3_bucket_object.key
  runtime       = "nodejs16.x"
  handler       = "index.handler"
  role          = aws_iam_role.lambda_exec_role.arn

  tags = {
    Environment = "${var.environment}"
  }
}

resource "aws_cloudwatch_log_group" "lambda_cloudwatch_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_function.function_name}"
  retention_in_days = 30

  tags = {
    Environment = "${var.environment}"
  }
}

# managed policy

resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.project_label}-lambda-exec-role"
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

  tags = {
    Environment = "${var.environment}"
  }
}

resource "aws_iam_role_policy_attachment" "lamda_role_policy_attachment" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"

}

#custom policy
resource "aws_iam_policy" "dynamodb_access_policy" {
  name        = "LambdaDynamodbExecution"
  path        = "/"
  description = "Lambda dynamodb access policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action : [
          "dynamodb:GetItem",
          "dynamodb:DeleteItem",
          "dynamodb:PutItem",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:UpdateItem",
          "dynamodb:BatchWriteItem",
          "dynamodb:BatchGetItem",
          "dynamodb:DescribeTable",
          "dynamodb:ConditionCheckItem"
        ],
        Resource : [
          "*",
        ],
        Effect : "Allow"
      }

    ]
  })

  tags = {
    Environment = "${var.environment}"
  }
}

resource "aws_iam_role_policy_attachment" "role_policy_attachment" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.dynamodb_access_policy.arn

}

# s3 object
data "archive_file" "archive_file" {
  type        = "zip"
  source_dir  = "${path.module}/src/lambda"
  output_path = "${path.module}/src/lambda.zip"
}

resource "aws_s3_bucket_object" "lambda_s3_bucket_object" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "lambda.zip"
  source = data.archive_file.archive_file.output_path
  etag   = filemd5(data.archive_file.archive_file.output_path)

  tags = {
    Environment = "${var.environment}"
  }
}

###########################################################################################################
# API GATEWAY
###########################################################################################################

resource "aws_apigatewayv2_api" "apigatewayv2_api" {
  name          = "${var.project_label}-apigatewayv2-api"
  protocol_type = "HTTP"

  tags = {
    Environment = "${var.environment}"
  }
}

resource "aws_apigatewayv2_stage" "apigatewayv2_stage" {
  api_id      = aws_apigatewayv2_api.apigatewayv2_api.id
  name        = "${var.project_label}-serverless-lambda-stage"
  auto_deploy = true
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.apigw_cloudwatch_log_group.arn
    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }

  tags = {
    Environment = "${var.environment}"
  }
}

# --INTEGRATIONS--

resource "aws_apigatewayv2_integration" "apigatewayv2_integration" {
  api_id                 = aws_apigatewayv2_api.apigatewayv2_api.id
  integration_uri        = aws_lambda_function.lambda_function.invoke_arn
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "any_apigatewayv2_route" {
  api_id    = aws_apigatewayv2_api.apigatewayv2_api.id
  route_key = "ANY /v1/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.apigatewayv2_integration.id}"
}


# ###########################################################################################################
# CLOUDWATCH
###########################################################################################################
resource "aws_cloudwatch_log_group" "apigw_cloudwatch_log_group" {
  name              = "/aws/api_gw/${aws_apigatewayv2_api.apigatewayv2_api.name}"
  retention_in_days = 30

  tags = {
    Environment = "${var.environment}"
  }
}

resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.apigatewayv2_api.execution_arn}/*/*"

}

