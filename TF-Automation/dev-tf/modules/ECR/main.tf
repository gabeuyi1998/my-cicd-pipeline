resource "aws_ecr_repository" "this" {
  count = var.create_repo ? 1 : 0
  name  = var.repo_name

  tags = {
    Environment = var.environment
  }
}

output "repo_url" {
  value = var.create_repo ? aws_ecr_repository.this[0].repository_url : data.aws_ecr_repository.existing_repo.repository_url
}