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

data "aws_instance" "simple_server" {
  instance_id = "i-04002736142d2b9e6"
}

resource "aws_instance" "simple_client" {
  ami           = "ami-083522e25d3e4d203"
  instance_type = "t4g.nano"
  key_name      = "simple_client"
  subnet_id     = data.aws_instance.simple_server.subnet_id

  user_data = <<-EOF
  #!/bin/bash
  sudo yum update -y
  sudo yum groupinstall "Development Tools" -y
  EOF

  tags = {
    Name = "EC2 Instance Simple Client"
  }
}

