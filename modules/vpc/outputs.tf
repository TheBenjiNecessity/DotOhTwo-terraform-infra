output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.dotohtwo_vpc_1.id
}

output "subnet_ids" {
  description = "The IDs of the public subnets"
  value       = [aws_subnet.subnet.id, aws_subnet.subnet2.id]
}

output "alb_security_group_id" {
  description = "The ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "ecs_instances_security_group_id" {
  description = "The ID of the ECS instances security group"
  value       = aws_security_group.ecs_instances.id
}
