terraform {
  backend "s3" {
    bucket         = "go-cicd-bucket"                # S3 bucket name for storing the state file
    key            = "dev/terraform.tfstate"         # Path to the state file within the S3 bucket (organized under "dev" directory)
    region         = "ap-southeast-2"                # AWS region where the S3 bucket and DynamoDB table are located
    dynamodb_table = "GO-TFstate-table"              # DynamoDB table for state locking and consistency
  }
}