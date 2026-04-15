# DotOhTwo Terraform Infrastructure

AWS infrastructure for the DotOhTwo platform, managed with Terraform. Provisions VPC, ECS cluster, RDS PostgreSQL, Amazon Keyspaces, Cognito, CodeArtifact, and supporting IAM/networking resources.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.0
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) configured with credentials that have sufficient permissions
- An AWS account with access to `us-east-1`

## Required Variables

Most variables have defaults, but the following **must** be supplied at apply time:

| Variable | Description |
|---|---|
| `db_password` | RDS PostgreSQL master password (sensitive) |

All other variables have sensible defaults defined in [variables.tf](variables.tf).

## Running the Project

### 1. Initialize

Downloads provider plugins and sets up the backend.

```bash
terraform init
```

### 2. Plan

Review what Terraform will create before applying. Pass required variables here.

```bash
terraform plan -var="db_password=<your-password>"
```

To persist variables across runs, create a `terraform.tfvars` file (do not commit this file):

```hcl
db_password = "your-secure-password"
```

### 3. Apply

```bash
terraform apply -var="db_password=<your-password>"
```

Confirm the prompt with `yes`. The first apply takes several minutes — RDS and ECS capacity providers are the slowest resources to provision.

### 4. Destroy

```bash
terraform destroy -var="db_password=<your-password>"
```

> **Note:** `skip_final_snapshot = true` is set on the RDS instance, so destroy will not create a snapshot before deleting the database.

## Module Overview

| Module | What it provisions |
|---|---|
| `vpc` | VPC, public/private subnets, ALB and ECS security groups |
| `ec2` | Launch template, Auto Scaling Group, ALB, target groups, listener rules |
| `ecs` | ECS cluster, capacity provider, task definitions and services for `dotohtwo-api` and `review-ingestor` |
| `rds` | PostgreSQL 16 instance, subnet group, security group, Secrets Manager secret |
| `keyspaces` | Amazon Keyspaces (Cassandra-compatible) keyspace |
| `cognito` | Cognito User Pool and App Client for JWT-based auth |
| `codeartifact` | CodeArtifact domain, `dotohtwo-libs` Maven repository, Maven Central upstream proxy, IAM publish/read policies |
| `iam` | EC2 instance role, ECS task execution role, ECS task runtime role with policies for Keyspaces, Secrets Manager, and CloudWatch Logs |

## Key Outputs

After a successful apply, Terraform prints:

| Output | Description |
|---|---|
| `load_balancer_dns` | DNS name of the ALB — the entry point for the REST API |
| `ecs_cluster_name` | Name of the ECS cluster (`dotohtwo-cluster`) |

## CodeArtifact (Spring Library Artifacts)

The `codeartifact` module provisions a `dotohtwo-libs` Maven repository for hosting shared Spring library JARs. To publish or consume artifacts from it, a caller must first obtain a short-lived auth token:

```bash
aws codeartifact get-authorization-token \
  --domain dotohtwo \
  --query authorizationToken \
  --output text
```

Attach the **publish** IAM policy (`module.codeartifact.publish_policy_arn`) to your CI/CD role, and the **read** IAM policy (`module.codeartifact.read_policy_arn`) to any build role that only consumes the library.

## ECR Image Expectations

The ECS task definitions pull images from ECR in the deploying account. Before the services start successfully, push images to:

- `<account-id>.dkr.ecr.us-east-1.amazonaws.com/dotohtwo-api:latest`
- `<account-id>.dkr.ecr.us-east-1.amazonaws.com/dotohtwo/review-ingestion-api:latest`
