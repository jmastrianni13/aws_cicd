provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "simple_server" {
  ami           = "ami-083522e25d3e4d203"
  instance_type = "t4g.micro"

  tags = {
    Name = "EC2 Instance Simple Server"
  }
}

