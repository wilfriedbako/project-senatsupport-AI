provider "aws" {
  region = "us-east-1"
}

# DynamoDB Table (Tickets)
resource "aws_dynamodb_table" "tickets" {
  name         = "SenatSupport-Tickets"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "TicketID"

  attribute {
    name = "TicketID"
    type = "S"
  }
}

# SNS Topic (Alerts)
resource "aws_sns_topic" "alerts" {
  name = "SenatSupport-Alerts"
}


# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "senatsupport-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Attach basic execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_dynamodb_policy" {
  name = "lambda-dynamodb-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "dynamodb:PutItem",
        "dynamodb:GetItem",
        "dynamodb:Scan"
      ],
      Resource = aws_dynamodb_table.tickets.arn
    }]
  })
}
# Lambda Function
resource "aws_lambda_function" "ticket_processor" {
  function_name = "SenatSupportProcessor"
  role          = aws_iam_role.lambda_role.arn
  handler       = "app.lambda_handler"
  runtime       = "python3.11"

  filename = "../lambda/lambda.zip"
source_code_hash = filebase64sha256("../lambda/lambda.zip")
}

# API Gateway
resource "aws_apigatewayv2_api" "api" {
  name          = "senatsupport-api"
  protocol_type = "HTTP"
}

output "api_url" {
  value = aws_apigatewayv2_api.api.api_endpoint
}

# Integration with Lambda
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.ticket_processor.invoke_arn
}

# Route (endpoint)
resource "aws_apigatewayv2_route" "route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /ticket"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Stage (deploy)
resource "aws_apigatewayv2_stage" "stage" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true
}

# Permission for API Gateway to call Lambda
resource "aws_lambda_permission" "api_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ticket_processor.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_iam_role_policy" "bedrock_policy" {
  name = "lambda-bedrock-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "bedrock:InvokeModel"
      ],
      Resource = "*"
    }]
  })
}



resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "bakowilfried52@gmail.com"
}

resource "aws_iam_role_policy" "lambda_sns_policy" {
  name = "lambda-sns-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "sns:Publish"
      ],
      Resource = aws_sns_topic.alerts.arn
    }]
  })
}