terraform {
  backend "s3" {
    bucket         = "devops-tf-state-pratik-12345"
    key            = "terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}