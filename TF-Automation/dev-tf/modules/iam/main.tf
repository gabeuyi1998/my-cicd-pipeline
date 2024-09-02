resource "aws_iam_role" "ecs_task_execution_role" {
  count = var.create_ecs_role ? 1 : 0
  name = var.ecs_task_execution_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
  tags = {
    Name        = var.ecs_task_execution_role_name
    Environment = var.environment
  }
}

resource "aws_iam_role" "ssm_role" {
  count = var.create_ssm_role ? 1 : 0
  name = var.ssm_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
  tags = {
    Name        = var.ssm_role_name
    Environment = var.environment
  }
}

resource "aws_iam_instance_profile" "ssm_profile" {
  count = var.create_ssm_role ? 1 : 0
  name = "${var.ssm_role_name}-profile"
  role = aws_iam_role.ssm_role[0].name
}

output "ecs_task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role[0].arn
}

output "ssm_profile_name" {
  value = aws_iam_instance_profile.ssm_profile[0].name
}