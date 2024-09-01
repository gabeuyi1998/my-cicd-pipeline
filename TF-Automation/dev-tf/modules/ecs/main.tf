resource "aws_ecs_cluster" "cluster" {
  name = var.cluster_name
  tags = {
    Name        = var.cluster_name
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
        awslogs-group         = "/ecs/${var.task_definition_name}"
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