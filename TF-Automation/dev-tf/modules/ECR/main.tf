resource "aws_ecr_repository" "this" {
  count = var.create_repo ? 1 : 0
  name  = var.repo_name

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Environment = var.environment
  }
}

output "repo_url" {
  value = var.create_repo ? aws_ecr_repository.this[0].repository_url : null
}