variable "repo_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "go-my-app-repo"
}

variable "environment" {
  description = "Environment (e.g., Production, Staging)"
  type        = string
  default     = "Production"
}

variable "ecs_task_execution_role_name" {
  description = "Name of the ECS task execution role"
  type        = string
  default     = "go-ecs-task-execution-role"
}

variable "ssm_role_name" {
  description = "Name of the SSM role"
  type        = string
  default     = "go-ssm-role"
}

variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
  default     = "go-my-ecs-cluster"
}

variable "task_definition_name" {
  description = "Name of the ECS task definition"
  type        = string
  default     = "go-my-app-task"
}

variable "subnets" {
  description = "List of subnets for the ECS service"
  type        = list(string)
  default     = ["subnet-08ee8d0f3aa0d548a"]
}

variable "security_groups" {
  description = "List of security groups for the ECS service"
  type        = list(string)
  default     = ["sg-0e9a23e8bdad9daac"]
}

variable "ami" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-0375ab65ee943a2a6"
}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "subnet_id" {
  description = "Subnet ID for the EC2 instance"
  type        = string
  default     = "subnet-08ee8d0f3aa0d548a"
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs for the EC2 instance"
  type        = list(string)
  default     = ["sg-0e9a23e8bdad9daac"]
}

variable "terraform_state_bucket" {
  description = "The name of the S3 bucket used for Terraform state"
  type        = string
  default     = "go-cicd-bucket"
}

variable "terraform_locks_table" {
  description = "The name of the DynamoDB table used for Terraform state locking"
  type        = string
  default     = "GO-TFstate-table"
}