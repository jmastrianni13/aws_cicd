provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "simple_server" {
  ami           = "ami-083522e25d3e4d203"
  instance_type = "t4g.micro"
  key_name      = "simple_server"

  user_data = <<-EOF
  #!/bin/bash
  sudo yum update -y
  sudo yum groupinstall "Development Tools" -y
  EOF

  tags = {
    Name = "EC2 Instance Simple Server"
  }
}

