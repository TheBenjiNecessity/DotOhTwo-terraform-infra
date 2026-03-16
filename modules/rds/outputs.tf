output "db_endpoint" {
  description = "RDS instance endpoint in host:port format"
  value       = aws_db_instance.dotohtwo_db.endpoint
}

output "db_secret_arn" {
  description = "ARN of the Secrets Manager secret containing the DB password"
  value       = aws_secretsmanager_secret.db_password.arn
}
