output "instance_profile_arn" {
  description = "ARN of the ECS EC2 instance profile"
  value       = aws_iam_instance_profile.ecs_instance_profile.arn
}

output "task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = aws_iam_role.ecs_task_execution_role.arn
}

output "task_role_arn" {
  description = "ARN of the ECS task role (assumed by the app container at runtime)"
  value       = aws_iam_role.ecs_task_role.arn
}
