# My CI/CD Pipeline Project

## Overview

This project demonstrates the creation of a fully automated CI/CD pipeline using Jenkins, Terraform, Docker, and Amazon ECS. The pipeline deploys a React web application, containerized with Docker, onto an ECS Fargate cluster. The application features a carousel of BMW images, hosted on AWS S3 and served via CloudFront.

<<<<<<< HEAD
## Architecture Diagram

Below is a simplified architecture diagram showing the components involved:

```plaintext
  GitHub --> Jenkins --> Terraform --> AWS (ECR, ECS, S3, CloudFront, DynamoDB)
         \__________________________/          \__________________________/
                          |                                      |
                    Code Repository                     Infrastructure & Services
=======
The project is divided into two main pipelines:
1. **Application CI/CD Pipeline**: Manages the build, push, and deployment of the application.
2. **Terraform Infrastructure Pipeline**: Manages the provisioning and management of AWS infrastructure using Terraform.

## Project Structure

The project is organized into the following structure:

```plaintext
my-cicd-pipeline/
├── app/
│   ├── node_modules/
│   ├── package-lock.json
│   ├── package.json
│   ├── public/
│   │   └── index.html
│   ├── src/
│   ├── Dockerfile
│   └── Jenkinsfile  # Application Jenkinsfile
├── README.md
├── TF-Automation/
│   ├── backend.tf
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── modules/
│   │   ├── ecr/
│   │   │   ├── main.tf
│   │   │   └── variables.tf
│   │   ├── ecs/
│   │   │   ├── main.tf
│   │   │   └── variables.tf
│   │   ├── iam/
│   │   │   ├── main.tf
│   │   │   └── variables.tf
│   │   └── ec2/
│   │       ├── main.tf
│   │       └── variables.tf
│   └── Jenkinsfile  # Terraform Jenkinsfile
├── Photo/Documentation/
```

## Jenkins Pipelines Overview

### 1. Application CI/CD Pipeline

The Application CI/CD Pipeline is responsible for building, pushing, and deploying the application. Below are the detailed steps taken in this pipeline:

#### Step 1: Clean Workspace

This step ensures a clean working directory by removing any files from previous builds.

```groovy
stage('Clean Workspace') {
    steps {
        cleanWs()
    }
}
```

#### Step 2: Checkout Code

Pulls the latest code from the `main` branch of the GitHub repository.

```groovy
stage('Checkout Code') {
    steps {
        git branch: 'main', 
            url: 'https://github.com/gabeuyi1998/my-cicd-pipeline.git',
            credentialsId: 'github-credentials'
    }
}
```

#### Step 3: Setup Docker Buildx

Sets up Docker Buildx to enable multi-platform image building.

```groovy
stage('Setup Docker Buildx') {
    steps {
        sh '''
        docker buildx create --name mybuilder --driver docker-container --use || docker buildx use mybuilder
        docker buildx inspect mybuilder --bootstrap
        '''
    }
}
```

#### Step 4: Build & Push Docker Image

Builds the Docker image for the application and pushes it to the Amazon ECR repository.

```groovy
stage('Build & Push Docker Image') {
    steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', 
                          credentialsId: 'aws-credentials']]) {
            dir('app') { 
                script {
                    def dockerImage = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ECR_REPO}:${BUILD_ID}"
                    sh """
                    docker buildx build --platform linux/amd64,linux/arm64 -t ${dockerImage} --push .
                    """
                }
            }
        }
    }
}
```

#### Step 5: Deploy to ECS

Deploys the Docker image from ECR to an ECS Fargate cluster.

```groovy
stage('Deploy to ECS') {
    steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', 
                          credentialsId: 'aws-credentials']]) {
            sh '''
            ecs-cli configure --cluster go-my-ecs-cluster --region $AWS_DEFAULT_REGION
            ecs-cli compose --file docker-compose.yml up || exit 1
            '''
        }
    }
}
```

#### Step 6: Deploy to Elastic Beanstalk

Optionally deploys the Docker container to Elastic Beanstalk.

```groovy
stage('Deploy to Elastic Beanstalk') {
    steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', 
                          credentialsId: 'aws-credentials']]) {
            sh '''
            eb init -p docker go-my-beanstalk-app --region $AWS_DEFAULT_REGION
            eb create go-my-environment || echo "Environment already exists"
            eb deploy || exit 1
            '''
        }
    }
}
```

### 2. Terraform Infrastructure Pipeline

The Terraform Infrastructure Pipeline is responsible for provisioning and managing the AWS resources required for the application. Below are the detailed steps taken in this pipeline:

#### Step 1: Clean Workspace

This step ensures a clean working directory by removing any files from previous builds.

```groovy
stage('Clean Workspace') {
    steps {
        cleanWs()
    }
}
```

#### Step 2: Checkout Terraform Code

Pulls the latest Terraform code from the `main` branch of the GitHub repository.

```groovy
stage('Checkout Terraform Code') {
    steps {
        git branch: 'main', 
            url: 'https://github.com/gabeuyi1998/my-cicd-pipeline.git',
            credentialsId: 'github-credentials'
    }
}
```

#### Step 3: Terraform Init & Apply

Initializes and applies the Terraform configurations to provision the necessary AWS resources.

```groovy
stage('Terraform Init & Apply') {
    steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', 
                          credentialsId: 'aws-credentials']]) {
            sh '''
            terraform -chdir=TF-Automation init -backend-config="bucket=$TF_BUCKET" -backend-config="dynamodb_table=$TF_DYNAMO_TABLE"
            terraform -chdir=TF-Automation apply -auto-approve || exit 1
            '''
        }
    }
}
```

## Terraform Modules

The Terraform infrastructure is organized into several reusable modules:

### 1. ECR Module

Manages the creation of the Amazon ECR repository.

#### `modules/ecr/main.tf`

```hcl
resource "aws_ecr_repository" "repo" {
  name = var.repo_name
  tags = {
    Name        = var.repo_name
    Environment = var.environment
  }
}

output "repo_url" {
  value = aws_ecr_repository.repo.repository_url
}
```

#### `modules/ecr/variables.tf`

```hcl
variable "repo_name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "environment" {
  description = "Environment (e.g., Production)"
  type        = string
}
```

### 2. ECS Module

Manages the creation of the ECS cluster and associated resources.

#### `modules/ecs/main.tf`

```hcl
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
```

#### `modules/ecs/variables.tf`

```hcl
variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "task_definition_name" {
  description = "Name of the ECS task definition"
  type        = string
}

variable "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  type        = string
}

variable "ecr_repo_url" {
  description = "URL of the ECR repository"
  type        = string
}

variable "subnets" {
  description = "List of subnets for the ECS service"
  type        = list(string)
}

variable "security_groups" {
  description = "List of security groups for the ECS service"
  type        = list(string)
}

variable "environment" {
  description = "Environment (e.g., Production)"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-southeast-2"
}
```

### 3. IAM Module

Manages the creation of IAM roles and instance profiles required for ECS tasks and EC2 instances.

#### `modules/iam/main.tf`

```hcl
resource "aws_iam_role" "ecs_task_execution_role" {
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

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ssm_role" {
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

resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "${var.ssm_role_name}-profile"
  role = aws_iam_role.ssm_role.name
}

output "ecs_task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}

output "ssm_profile_name" {
  value = aws_iam_instance_profile.ssm_profile.name
}
```

#### `modules/iam/variables.tf`

```hcl
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
```

### 4. EC2 Module

Manages the creation of EC2 instances with the necessary configurations.

#### `modules/ec2/main.tf`

```hcl
resource "aws_instance" "app_server" {
  ami                  = var.ami
  instance_type        = var.instance_type
  subnet_id            = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids
  iam_instance_profile = var.iam_instance_profile_name
  tags = {
    Name        = "${var.environment}-app-server"
    Environment = var.environment
  }
}

output "instance_id" {
  value = aws_instance.app_server.id
}
```

#### `modules/ec2/variables.tf`

```hcl
variable "ami" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the EC2 instance"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs for the EC2 instance"
  type        = list(string)
}

variable "iam_instance_profile_name" {
  description = "Name of the IAM instance profile"
  type        = string
}

variable "environment" {
  description = "Environment (e.g., Production)"
  type        = string
}
```

## Conclusion

This `README.md` provides a comprehensive guide for setting up and managing a CI/CD pipeline that deploys a React application to AWS using Jenkins, Docker, and Terraform. The document covers all the steps in detail, from setting up the application pipeline to provisioning the necessary AWS infrastructure with Terraform.

The project is structured to be modular and scalable, with each component of the infrastructure encapsulated in reusable Terraform modules. The Jenkins pipelines are designed to be straightforward and easy to maintain, enabling continuous integration and delivery of my application.

>>>>>>> b9024989 (File-structure-fix)
