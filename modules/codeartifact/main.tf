resource "aws_codeartifact_domain" "dotohtwo" {
  domain = "dotohtwo"
}

# Upstream Maven Central so builds can proxy public deps through CodeArtifact
resource "aws_codeartifact_repository" "maven_central_upstream" {
  repository = "maven-central-store"
  domain     = aws_codeartifact_domain.dotohtwo.domain

  external_connections {
    external_connection_name = "public:maven-central"
  }
}

resource "aws_codeartifact_repository" "dotohtwo_libs" {
  repository = "dotohtwo-libs"
  domain     = aws_codeartifact_domain.dotohtwo.domain

  upstream {
    repository_name = aws_codeartifact_repository.maven_central_upstream.repository
  }
}

# Policy allowing CI/CD to publish artifacts
resource "aws_iam_policy" "codeartifact_publish" {
  name        = "dotohtwo-codeartifact-publish"
  description = "Allows publishing Spring library artifacts to CodeArtifact"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "codeartifact:GetAuthorizationToken",
          "codeartifact:GetRepositoryEndpoint",
          "codeartifact:PublishPackageVersion",
          "codeartifact:PutPackageMetadata",
          "codeartifact:ReadFromRepository"
        ]
        Resource = [
          aws_codeartifact_domain.dotohtwo.arn,
          aws_codeartifact_repository.dotohtwo_libs.arn,
          aws_codeartifact_repository.maven_central_upstream.arn
        ]
      },
      {
        Effect   = "Allow"
        Action   = "sts:GetServiceBearerToken"
        Resource = "*"
        Condition = {
          StringEquals = {
            "sts:AWSServiceName" = "codeartifact.amazonaws.com"
          }
        }
      }
    ]
  })
}

# Policy allowing read-only access (for builds that consume the library)
resource "aws_iam_policy" "codeartifact_read" {
  name        = "dotohtwo-codeartifact-read"
  description = "Allows reading Spring library artifacts from CodeArtifact"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "codeartifact:GetAuthorizationToken",
          "codeartifact:GetRepositoryEndpoint",
          "codeartifact:ReadFromRepository"
        ]
        Resource = [
          aws_codeartifact_domain.dotohtwo.arn,
          aws_codeartifact_repository.dotohtwo_libs.arn,
          aws_codeartifact_repository.maven_central_upstream.arn
        ]
      },
      {
        Effect   = "Allow"
        Action   = "sts:GetServiceBearerToken"
        Resource = "*"
        Condition = {
          StringEquals = {
            "sts:AWSServiceName" = "codeartifact.amazonaws.com"
          }
        }
      }
    ]
  })
}
