variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI/profile name to use"
  type        = string
  default     = "default"
}

variable "environment" {
  description = "Deployment environment (dev, stage, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "environment must be one of: dev, stage, prod"
  }
}

variable "project" {
  description = "Project name used in resource names/tags"
  type        = string
  default     = "dotohtwo"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones (full names, e.g. us-east-1a)"
  type        = list(string)
  default     = []
}

variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "List of private subnet CIDRs"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "instance_type" {
  description = "EC2 instance type for compute"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID to use for EC2 instances. If empty, use a data source to look up latest AMI."
  type        = string
  default     = ""
}

variable "key_name" {
  description = "EC2 key pair name for SSH access (empty = none)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Optional map of tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "s3_bucket_name" {
  description = "Optional S3 bucket name to create or use"
  type        = string
  default     = ""
}

variable "enable_s3_versioning" {
  description = "Enable versioning on created S3 buckets"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "Optional KMS key ARN for encryption (leave empty to use default AWS-managed keys)"
  type        = string
  default     = ""
}

variable "db_username" {
  description = "RDS master username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "RDS master password (sensitive)"
  type        = string
  sensitive   = true
  default     = null
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}