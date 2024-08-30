provider "aws" {
  region = "ap-southeast-2"
}

# Create the ECR repository
resource "aws_ecr_repository" "repo" {
  name = "go-my-app-repo"  # Updated to meet naming constraints

  tags = {
    Name = "go-my-app-repo"
    Environment = "Production"
  }
}

# Create the ECS cluster
resource "aws_ecs_cluster" "cluster" {
  name = "go-my-ecs-cluster"

  tags = {
    Name = "go-my-ecs-cluster"
    Environment = "Production"
  }
}

# Create the IAM role for ECS task execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "go-ecs-task-execution-role"

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
    Name = "go-ecs-task-execution-role"
    Environment = "Production"
  }
}

# Attach the necessary policy for ECS task execution
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Create the ECS task definition
resource "aws_ecs_task_definition" "task" {
  family                = "go-my-app-task"
  network_mode          = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                   = "256"
  memory                = "512"
  execution_role_arn    = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([{
    name      = "app"
    image     = "${aws_ecr_repository.repo.repository_url}:latest"
    essential = true
    portMappings = [{
      containerPort = 3000
      hostPort      = 3000
    }]
  }])

  tags = {
    Name = "go-my-app-task"
    Environment = "Production"
  }
}

# Create the ECS service
resource "aws_ecs_service" "service" {
  name            = "go-my-ecs-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
  #DYnamic subnets and security  
    subnets          = ["subnet-08ee8d0f3aa0d548a", "subnet-0b498229169ed1048"]  # Your provided subnets
    security_groups  = ["sg-0e9a23e8bdad9daac"]       # Use your specified security group
    assign_public_ip = true
  }

  tags = {
    Name = "go-my-ecs-service"
    Environment = "Production"
  }
}