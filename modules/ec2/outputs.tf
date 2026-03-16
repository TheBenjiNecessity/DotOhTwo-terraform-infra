output "dotohtwo_asg_arn" {
  description = "The ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.dotohtwo_asg.arn
}

output "dotohtwo_targetgroup_arn" {
  description = "The ARN of the Target Group"
  value       = aws_lb_target_group.dotohtwo_targetgroup.arn
}

output "dotohtwo_targetgroup_port" {
  description = "The port of the Target Group"
  value       = aws_lb_target_group.dotohtwo_targetgroup.port
}

output "dotohtwo_review_ingestor_tg_arn" {
  description = "The ARN of the review ingestor Target Group"
  value       = aws_lb_target_group.dotohtwo_review_ingestor_tg.arn
}

output "dotohtwo_loadbalancer_dns" {
  description = "The DNS name of the Load Balancer"
  value       = aws_lb.dotohtwo_loadbalancer.dns_name
}