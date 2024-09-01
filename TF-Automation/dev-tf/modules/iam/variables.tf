variable "ecs_task_execution_role_name" {
  description = "Name of the ECS task execution role"
  type        = string
}

variable "ssm_role_name" {
  description = "Name of the SSM role"
  type        = string
}

variable "environment" {
  description = "Environment (e.g., Production)"
  type        = string
}