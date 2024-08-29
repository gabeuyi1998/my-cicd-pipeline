provider "aws" {
  region = "ap-southeast-2"
}

# Create the ECR repository
resource "aws_ecr_repository" "repo" {
  name = "GO_my-app-repo"

  tags = {
    Name        = "GO_my-app-repo"
    Environment = "Production"
  }
}

# Create the ECS cluster
resource "aws_ecs_cluster" "cluster" {
  name = "GO_my-ecs-cluster"

  tags = {
    Name        = "GO_my-ecs-cluster"
    Environment = "Production"
  }
}

# Create the ECS task definition
resource "aws_ecs_task_definition" "task" {
  family                = "GO_my-app-task"
  network_mode          = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                   = "256"
  memory                = "512"
  execution_role_arn    = "arn:aws:iam::866934333672:role/ecs-task-role"  
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
    Name        = "GO_my-app-task"
    Environment = "Production"
  }
}

# Create the ECS service
resource "aws_ecs_service" "service" {
  name            = "GO_my-ecs-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = ["subnet-08ee8d0f3aa0d548a", "subnet-0b498229169ed1048"]  
    security_groups  = ["sg-0e9a23e8bdad9daac"]      
    assign_public_ip = true
  }

  tags = {
    Name        = "GO_my-ecs-service"
    Environment = "Production"
  }
}