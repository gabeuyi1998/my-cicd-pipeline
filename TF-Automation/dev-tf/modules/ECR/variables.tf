variable "repo_name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "environment" {
  description = "Environment (e.g., Production)"
  type        = string
}
variable "create_repo" {
  description = "Flag to determine whether to create the ECR repository"
  type        = bool
  default     = true
}