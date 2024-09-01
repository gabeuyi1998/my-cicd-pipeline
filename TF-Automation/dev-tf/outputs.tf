output "ecr_repo_url" {
  value = module.ecr.repo_url
  description = "The URL of the ECR repository"
}

output "ecs_cluster_id" {
  value = module.ecs.cluster_id
  description = "The ID of the ECS cluster"
}

output "instance_id" {
  value = module.ec2.instance_id
  description = "The ID of the EC2 instance"
}