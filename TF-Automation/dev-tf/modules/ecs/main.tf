resource "aws_ecs_cluster" "cluster" {
  name = var.cluster_name
  tags = {
    Name        = var.cluster_name
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/${var.task_definition_name}"
  retention_in_days = 7
  tags = {
    Environment = var.environment
  }
}

resource "aws_ecs_task_definition" "task" {
  family                   = var.task_definition_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.ecs_task_execution_role_arn
  container_definitions    = jsonencode([{
    name      = "app"
    image     = "${var.ecr_repo_url}:latest"
    essential = true
    portMappings = [{
      containerPort = 3000
      hostPort      = 3000
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs_log_group.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "ecs"
      }
    }
  }])

  tags = {
    Name        = var.task_definition_name
    Environment = var.environment
  }
}

resource "aws_ecs_service" "service" {
  name            = "${var.cluster_name}-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = var.subnets
    security_groups = var.security_groups
    assign_public_ip = true
  }

  tags = {
    Name        = "${var.cluster_name}-service"
    Environment = var.environment
  }
}

output "cluster_id" {
  value = aws_ecs_cluster.cluster.id
}

output "service_name" {
  value = aws_ecs_service.service.name
}

output "task_definition_arn" {
  value = aws_ecs_task_definition.task.arn
}

output "ecs_service_url" {
  value = aws_ecs_service.service.network_configuration[0].assign_public_ip ? "Public IP Assigned" : "No Public IP"
}