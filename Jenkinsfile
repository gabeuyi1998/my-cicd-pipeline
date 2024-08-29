pipeline {
    agent any
    environment {
        AWS_DEFAULT_REGION = 'ap-southeast-2'
        TF_BUCKET = 'go-cicd-bucket'
        TF_DYNAMO_TABLE = 'GO-TFstate-table'
        ECR_REPO = 'GO_my-app-repo'
        DOCKER_IMAGE = ''
    }
    stages {
        stage('Checkout Code') {
            steps {
                git 'https://github.com/gabeuyi1998/my-cicd-pipeline.git'
            }
        }
        stage('Terraform Init & Apply') {
            steps {
                sh 'terraform init -backend-config="bucket=$TF_BUCKET" -backend-config="dynamodb_table=$TF_DYNAMO_TABLE"'
                sh 'terraform apply -auto-approve'
            }
        }
        stage('Build & Push Docker Image') {
            steps {
                script {
                    DOCKER_IMAGE = docker.build("$ECR_REPO:$BUILD_ID")
                    docker.withRegistry('https://866934333672.dkr.ecr.ap-southeast-2.amazonaws.com', 'ecr:login') {
                        DOCKER_IMAGE.push()
                    }
                }
            }
        }
        stage('Deploy to ECS') {
            steps {
                script {
                    sh 'ecs-cli compose --project-name GO_my-ecs-service service up --create-log-groups --cluster-config GO_my-ecs-cluster-config --ecs-profile my-ecs-profile'
                }
            }
        }
    }
}