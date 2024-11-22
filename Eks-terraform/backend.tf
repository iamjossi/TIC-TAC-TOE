terraform {
  backend "s3" {
    bucket = "jossigameapp2024" # Replace with your actual S3 bucket name
    key    = "EKS/terraform.tfstate"
    region = "eu-west-2"
  }
}
