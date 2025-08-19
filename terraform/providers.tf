terraform {
  backend "s3" {
    bucket = "terraform"
    key    = "aws_cicd"
    region = "us-east-1"
  }
}

