# AWS Provider Configuration
provider "aws" {
  region = var.region
}

# ECR Module
data "aws_ecr_repository" "existing_repo" {
  name = var.repo_name
}

module "ecr" {
  source      = "./modules/ECR"
  repo_name   = var.repo_name
  environment = var.environment
  create_repo = length(data.aws_ecr_repository.existing_repo) == 0 ? true : false
}

# IAM Module
data "aws_iam_role" "existing_ecs_role" {
  name = var.ecs_task_execution_role_name
}

data "aws_iam_role" "existing_ssm_role" {
  name = var.ssm_role_name
}

module "iam" {
  source                     = "./modules/iam"
  environment                = var.environment
  ecs_task_execution_role_name = var.ecs_task_execution_role_name
  ssm_role_name              = var.ssm_role_name
  create_ecs_role            = length(data.aws_iam_role.existing_ecs_role) == 0 ? true : false
  create_ssm_role            = length(data.aws_iam_role.existing_ssm_role) == 0 ? true : false
}

# ECS Module
module "ecs" {
  source                  = "./modules/ecs"
  cluster_name            = var.cluster_name
  environment             = var.environment
  task_definition_name    = var.task_definition_name
  ecr_repo_url            = module.ecr.repo_url
  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  subnets                 = var.subnets
  security_groups         = var.security_groups
}

# EC2 Module
module "ec2" {
  source                   = "./modules/ec2"
  environment              = var.environment
  ami                      = var.ami
  instance_type            = var.instance_type
  subnet_id                = var.subnet_id
  vpc_security_group_ids   = var.vpc_security_group_ids
  iam_instance_profile_name = module.iam.ssm_profile_name
}