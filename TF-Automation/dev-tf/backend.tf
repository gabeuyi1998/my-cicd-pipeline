terraform {
  backend "s3" {
    bucket         = "go-cicd-bucket"
    key            = "dev/terraform.tfstate"  # Organized under "dev" directory in the S3 bucket
    region         = "ap-southeast-2"
    dynamodb_table = "GO-TFstate-table"
  }
}