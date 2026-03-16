variable "vpc_id" {
  description = "VPC ID for the RDS instance"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the DB subnet group (must span at least 2 AZs)"
  type        = list(string)
}

variable "ecs_instances_security_group_id" {
  description = "Security group ID of ECS instances allowed to connect on port 5432"
  type        = string
}

variable "db_password" {
  description = "Master password for the PostgreSQL database"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}
