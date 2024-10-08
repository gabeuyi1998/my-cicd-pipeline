resource "aws_iam_role" "ecs_task_execution_role" {
  count = var.create_ecs_role ? 1 : 0
  name  = var.ecs_task_execution_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      }
    }
  ]
}
EOF

  tags = {
    Environment = var.environment
  }
}

output "ecs_task_execution_role_arn" {
  value = var.create_ecs_role ? aws_iam_role.ecs_task_execution_role[0].arn : data.aws_iam_role.existing_ecs_role.arn
}

resource "aws_iam_instance_profile" "ssm_profile" {
  count = var.create_ssm_role ? 1 : 0
  name  = var.ssm_role_name
  role  = aws_iam_role.ssm_role.name

  tags = {
    Environment = var.environment
  }
}

output "ssm_profile_name" {
  value = var.create_ssm_role ? aws_iam_instance_profile.ssm_profile[0].name : data.aws_iam_role.existing_ssm_role.name
}