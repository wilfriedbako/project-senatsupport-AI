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

# DynamoDB permissions
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
        "dynamodb:Scan",
        "dynamodb:UpdateItem"
      ],
      Resource = aws_dynamodb_table.tickets.arn
    }]
  })
}

# Bedrock permissions
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

# SNS permissions
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

# Main ticket creation Lambda
resource "aws_lambda_function" "ticket_handler" {

  function_name = "senatsupport-handler"

  role = aws_iam_role.lambda_role.arn

  package_type = "Image"

  image_uri = "490848272326.dkr.ecr.us-east-1.amazonaws.com/senatsupport-lambda:latest"

  timeout = 30

  environment {
    variables = {
      TABLE_NAME   = aws_dynamodb_table.tickets.name
      SNS_TOPIC_ARN = aws_sns_topic.alerts.arn
    }
  }
}

# Ticket lifecycle update Lambda
resource "aws_lambda_function" "update_ticket" {

  function_name = "senatsupport-update-ticket"

  package_type = "Image"

  image_uri = "490848272326.dkr.ecr.us-east-1.amazonaws.com/senatsupport-lambda:latest"

  role = aws_iam_role.lambda_role.arn

  image_config {
    command = ["update_ticket.lambda_handler"]
  }

  timeout = 30
}

# API Gateway
resource "aws_apigatewayv2_api" "api" {
  name          = "senatsupport-api"
  protocol_type = "HTTP"
}

output "api_url" {
  value = aws_apigatewayv2_api.api.api_endpoint
}

# Main ticket integration
resource "aws_apigatewayv2_integration" "lambda_integration" {

  api_id = aws_apigatewayv2_api.api.id

  integration_type = "AWS_PROXY"

  integration_uri = aws_lambda_function.ticket_handler.invoke_arn

  integration_method = "POST"

  payload_format_version = "2.0"
}

# Update ticket integration
resource "aws_apigatewayv2_integration" "update_ticket_integration" {

  api_id = aws_apigatewayv2_api.api.id

  integration_type = "AWS_PROXY"

  integration_uri = aws_lambda_function.update_ticket.invoke_arn

  integration_method = "POST"

  payload_format_version = "2.0"
}

# Create ticket route
resource "aws_apigatewayv2_route" "route" {

  api_id = aws_apigatewayv2_api.api.id

  route_key = "POST /ticket"

  target = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Update ticket route
resource "aws_apigatewayv2_route" "update_ticket_route" {

  api_id = aws_apigatewayv2_api.api.id

  route_key = "PATCH /ticket/{id}"

  target = "integrations/${aws_apigatewayv2_integration.update_ticket_integration.id}"
}

# Stage
resource "aws_apigatewayv2_stage" "stage" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true
}

# Permission for main Lambda
resource "aws_lambda_permission" "api_permission" {

  statement_id = "AllowAPIGatewayInvoke"

  action = "lambda:InvokeFunction"

  function_name = aws_lambda_function.ticket_handler.function_name

  principal = "apigateway.amazonaws.com"
}

# Permission for update Lambda
resource "aws_lambda_permission" "update_ticket_permission" {

  statement_id = "AllowAPIGatewayInvokeUpdate"

  action = "lambda:InvokeFunction"

  function_name = aws_lambda_function.update_ticket.function_name

  principal = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

# Email subscription
resource "aws_sns_topic_subscription" "email_alert" {

  topic_arn = aws_sns_topic.alerts.arn

  protocol = "email"

  endpoint = "bakowilfried52@gmail.com"
}

# CloudWatch Alarm
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {

  alarm_name = "SenatSupport-Lambda-Errors"

  comparison_operator = "GreaterThanThreshold"

  evaluation_periods = 1

  metric_name = "Errors"

  namespace = "AWS/Lambda"

  period = 60

  statistic = "Sum"

  threshold = 1

  dimensions = {
    FunctionName = aws_lambda_function.ticket_handler.function_name
  }

  alarm_description = "Triggers when Lambda has errors"

  alarm_actions = [
    aws_sns_topic.alerts.arn
  ]
}