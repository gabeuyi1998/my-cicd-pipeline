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
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }
        stage('Checkout Code') {
            steps {
                git branch: 'main', 
                    url: 'https://github.com/gabeuyi1998/my-cicd-pipeline.git',
                    credentialsId: 'github-credentials'
            }
        }
        stage('Terraform Init & Apply') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', 
                                  credentialsId: 'aws-credentials']]) {
                    sh '''
                    terraform init -backend-config="bucket=$TF_BUCKET" -backend-config="dynamodb_table=$TF_DYNAMO_TABLE"
                    terraform apply -auto-approve || exit 1
                    '''
                }
            }
        }
        stage('Setup Docker Buildx') {
            steps {
                sh '''
                docker buildx create --name mybuilder --driver docker-container --use || docker buildx use mybuilder
                docker buildx inspect mybuilder --bootstrap
                '''
            }
        }
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
    }
    post {
        always {
            echo 'Pipeline finished.'
        }
        success {
            echo 'Pipeline succeeded.'
        }
        failure {
            echo 'Pipeline failed. Please check the logs.'
        }
    }
}