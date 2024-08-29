terraform {
  backend "s3" {
    bucket         = "go-cicd-bucket"       
    key            = "terraform.tfstate"     
    region         = "ap-southeast-2"        
    dynamodb_table = "GO-TFstate-table"      
  }
}