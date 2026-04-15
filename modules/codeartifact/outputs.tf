output "domain_name" {
  description = "CodeArtifact domain name"
  value       = aws_codeartifact_domain.dotohtwo.domain
}

output "repository_name" {
  description = "Name of the dotohtwo-libs Maven repository"
  value       = aws_codeartifact_repository.dotohtwo_libs.repository
}

output "repository_endpoint" {
  description = "Maven endpoint URL for the dotohtwo-libs repository"
  value       = aws_codeartifact_repository.dotohtwo_libs.repository_endpoint
}

output "publish_policy_arn" {
  description = "ARN of the IAM policy granting publish access to CodeArtifact"
  value       = aws_iam_policy.codeartifact_publish.arn
}

output "read_policy_arn" {
  description = "ARN of the IAM policy granting read access to CodeArtifact"
  value       = aws_iam_policy.codeartifact_read.arn
}
