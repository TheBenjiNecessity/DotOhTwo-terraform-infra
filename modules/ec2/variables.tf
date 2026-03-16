variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ASG and ALB"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID for the ALB"
  type        = string
}

variable "ecs_instances_security_group_id" {
  description = "Security group ID for the ECS EC2 instances"
  type        = string
}

variable "instance_profile_arn" {
  description = "ARN of the IAM instance profile to attach to EC2 instances"
  type        = string
}

variable "cluster_name" {
  description = "ECS cluster name - written to ecs.config so instances register to the right cluster"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "desired_capacity" {
  description = "Desired number of EC2 instances in the ASG"
  type        = number
  default     = 1
}

variable "min_size" {
  description = "Minimum number of EC2 instances in the ASG"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of EC2 instances in the ASG"
  type        = number
  default     = 4
}
