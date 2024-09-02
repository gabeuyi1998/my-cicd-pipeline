output "ec2_instance_id" {
  description = "The ID of the EC2 instance"
  value       = module.ec2.instance_id
}

output "ec2_public_ip" {
  description = "The public IP of the EC2 instance"
  value       = module.ec2.public_ip
}

output "ecr_repo_url" {
  description = "The URL of the ECR repository"
  value       = module.ecr.repo_url
}

output "ecs_cluster_id" {
  description = "The ID of the ECS cluster"
  value       = module.ecs.cluster_id
}

output "ecs_service_name" {
  description = "The name of the ECS service"
  value       = module.ecs.service_name
}

output "ecs_task_definition_arn" {
  description = "The ARN of the ECS task definition"
  value       = module.ecs.task_definition_arn
}

output "ecs_task_execution_role_arn" {
  description = "The ARN of the ECS task execution role"
  value       = module.iam.ecs_task_execution_role_arn
}

output "ssm_profile_name" {
  description = "The name of the SSM instance profile"
  value       = module.iam.ssm_profile_name
}