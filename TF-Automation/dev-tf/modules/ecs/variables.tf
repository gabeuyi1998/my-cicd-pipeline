variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "task_definition_name" {
  description = "Name of the ECS task definition"
  type        = string
}

variable "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  type        = string
}

variable "ecr_repo_url" {
  description = "URL of the ECR repository"
  type        = string
}

variable "subnets" {
  description = "List of subnets for the ECS service"
  type        = list(string)
}

variable "security_groups" {
  description = "List of security groups for the ECS service"
  type        = list(string)
}

variable "environment" {
  description = "Environment (e.g., Production)"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-southeast-2"
}