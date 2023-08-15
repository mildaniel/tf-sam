resource "aws_api_gateway_rest_api" "api" {
  name = "Terraform REST Example"
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.open_resource.id,
      aws_api_gateway_method.open_get_method.id,
      aws_api_gateway_integration.open_integration.id,
      aws_api_gateway_resource.secure_resource.id,
      aws_api_gateway_method.secure_get_method.id,
      aws_api_gateway_integration.secure_integration.id
    ]))
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "prod"
}

#######################################
## Open endpoint                     ##
#######################################

resource "aws_api_gateway_resource" "open_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id = aws_api_gateway_rest_api.api.root_resource_id
  path_part = "open"
}

resource "aws_api_gateway_method" "open_get_method" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.open_resource.id
  http_method = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "open_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.open_resource.id
  http_method = aws_api_gateway_method.open_get_method.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  content_handling = "CONVERT_TO_TEXT"
  uri = module.lambda_function_hello.lambda_function_invoke_arn
}

#######################################
## Secure endpoint                   ##
#######################################

resource "aws_api_gateway_resource" "secure_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id = aws_api_gateway_rest_api.api.root_resource_id
  path_part = "secure"
}

resource "aws_api_gateway_method" "secure_get_method" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.secure_resource.id
  http_method = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "secure_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.secure_resource.id
  http_method = aws_api_gateway_method.secure_get_method.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  content_handling = "CONVERT_TO_TEXT"
  uri = module.lambda_function_hello.lambda_function_invoke_arn
}