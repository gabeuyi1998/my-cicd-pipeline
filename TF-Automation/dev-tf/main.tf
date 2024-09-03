# AWS Provider Configuration
provider "aws" {
  region = var.region
  assume_role {
    role_arn = var.cicd_pipeline_role_arn
  }
}

# ECR Module
data "aws_ecr_repository" "existing_repo" {
  name = var.repo_name
}

module "ecr" {
  source      = "./modules/ECR"
  repo_name   = var.repo_name
  environment = var.environment
  create_repo = try(length(data.aws_ecr_repository.existing_repo.id) == 0, true)
}

output "ecr_repo_url" {
  description = "The URL of the ECR repository"
  value       = module.ecr.repo_url
}

# IAM Module
data "aws_iam_role" "existing_ecs_role" {
  name = var.ecs_task_execution_role_name
}

data "aws_iam_role" "existing_ssm_role" {
  name = var.ssm_role_name
}

module "iam" {
  source                       = "./modules/iam"
  environment                  = var.environment
  ecs_task_execution_role_name = var.ecs_task_execution_role_name
  ssm_role_name                = var.ssm_role_name
  create_ecs_role              = try(length(data.aws_iam_role.existing_ecs_role.id) == 0, true)
  create_ssm_role              = try(length(data.aws_iam_role.existing_ssm_role.id) == 0, true)
}

output "ecs_task_execution_role_arn" {
  description = "The ARN of the ECS task execution role"
  value       = module.iam.ecs_task_execution_role_arn
}

output "ssm_profile_name" {
  description = "The name of the SSM instance profile"
  value       = module.iam.ssm_profile_name
}

# ECS Module
module "ecs" {
  source                       = "./modules/ecs"
  cluster_name                 = var.cluster_name
  environment                  = var.environment
  task_definition_name         = var.task_definition_name
  ecr_repo_url                 = module.ecr.repo_url
  ecs_task_execution_role_arn  = module.iam.ecs_task_execution_role_arn
  subnets                      = var.subnets
  security_groups              = var.security_groups
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

# EC2 Module
module "ec2" {
  source                    = "./modules/ec2"
  environment               = var.environment
  ami                       = var.ami
  instance_type             = var.instance_type
  subnet_id                 = var.subnet_id
  vpc_security_group_ids    = var.vpc_security_group_ids
  iam_instance_profile_name = module.iam.ssm_profile_name
}

output "ec2_instance_id" {
  description = "The ID of the EC2 instance"
  value       = module.ec2.instance_id
}

output "ec2_public_ip" {
  description = "The public IP of the EC2 instance"
  value       = module.ec2.public_ip
}