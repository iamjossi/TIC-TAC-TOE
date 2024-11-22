terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "ec2-instance/terraform.tfstate"
    region         = "eu-west-2"
  }
}
