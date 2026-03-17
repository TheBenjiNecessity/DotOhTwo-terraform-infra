output "user_pool_id" {
  description = "Cognito User Pool ID"
  value       = aws_cognito_user_pool.dotohtwo_user_pool.id
}

output "user_pool_arn" {
  description = "Cognito User Pool ARN"
  value       = aws_cognito_user_pool.dotohtwo_user_pool.arn
}

output "user_pool_client_id" {
  description = "Cognito App Client ID"
  value       = aws_cognito_user_pool_client.dotohtwo_user_pool_client.id
}

output "issuer_uri" {
  description = "JWT issuer URI for Spring Boot resource server configuration"
  value       = "https://cognito-idp.us-east-1.amazonaws.com/${aws_cognito_user_pool.dotohtwo_user_pool.id}"
}
