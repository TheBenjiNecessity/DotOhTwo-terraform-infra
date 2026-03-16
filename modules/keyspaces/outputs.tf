output "keyspace_name" {
  description = "Name of the Keyspaces keyspace"
  value       = aws_keyspaces_keyspace.dotohtwo.name
}

output "keyspace_arn" {
  description = "ARN of the Keyspaces keyspace"
  value       = aws_keyspaces_keyspace.dotohtwo.arn
}
