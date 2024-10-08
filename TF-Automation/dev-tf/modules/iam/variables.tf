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
variable "create_ecs_role" {
  description = "Flag to determine whether to create the ECS task execution role"
  type        = bool
  default     = true
}

variable "create_ssm_role" {
  description = "Flag to determine whether to create the SSM role"
  type        = bool
  default     = true
}
variable "cicd_pipeline_role_arn" {
  description = "ARN of the IAM role used for the CI/CD pipeline"
  type        = string
  default     = "arn:aws:iam::866934333672:role/GO_CICD-Pipeline-Role"
}