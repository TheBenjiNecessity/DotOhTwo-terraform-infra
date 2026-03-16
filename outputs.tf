output "load_balancer_dns" {
  description = "DNS name of the Application Load Balancer - use this to reach the REST API"
  value       = module.ec2.dotohtwo_loadbalancer_dns
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = "dotohtwo-cluster"
}
