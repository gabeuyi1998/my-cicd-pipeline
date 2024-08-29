pipeline {
    agent any
    environment {
        AWS_DEFAULT_REGION = 'ap-southeast-2'
        TF_BUCKET = 'go-cicd-bucket'
        TF_DYNAMO_TABLE = 'GO-TFstate-table'
        ECR_REPO = 'go-my-app-repo'
        DOCKER_IMAGE = ''
        AWS_ACCOUNT_ID = '866934333672' 
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
                    DOCKER_IMAGE = docker.build("$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$ECR_REPO:$BUILD_ID")
                    docker.withRegistry("https://$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com", 'ecr:login') {
                        DOCKER_IMAGE.push()
                    }
                }
            }
        }
        stage('Deploy to ECS') {
            steps {
                sh '''
                ecs-cli configure --cluster go-my-ecs-cluster --region $AWS_DEFAULT_REGION
                ecs-cli compose --file docker-compose.yml up
                '''
            }
        }
        stage('Deploy to Elastic Beanstalk') {
            steps {
                sh '''
                eb init -p docker go-my-beanstalk-app --region $AWS_DEFAULT_REGION
                eb create go-my-environment
                eb deploy
                '''
            }
        }
    }
}