variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for awsvpc task network interfaces"
  type        = list(string)
}

variable "ecs_tasks_security_group_id" {
  description = "Security group ID attached to each task's ENI"
  type        = string
}

variable "dotohtwo_asg_arn" {
  description = "ARN of the Auto Scaling Group backing the capacity provider"
  type        = string
}

variable "dotohtwo_targetgroup_arn" {
  description = "ARN of the ALB target group for the ECS service"
  type        = string
}

variable "review_ingestor_targetgroup_arn" {
  description = "ARN of the ALB target group for the review ingestor service"
  type        = string
}

variable "execution_role_arn" {
  description = "ARN of the IAM role used by ECS to pull images and write logs"
  type        = string
}

variable "task_role_arn" {
  description = "ARN of the IAM role assumed by the application container at runtime"
  type        = string
}

variable "keyspace_name" {
  description = "Amazon Keyspaces keyspace name"
  type        = string
}

variable "db_endpoint" {
  description = "RDS endpoint in host:port format"
  type        = string
}

variable "db_secret_arn" {
  description = "ARN of the Secrets Manager secret containing the database password"
  type        = string
}
