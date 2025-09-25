provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_subnet" "simple_subnet" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = "use1-az1"
}

resource "aws_security_group" "simple_sg" {
  name        = "simle-server-client-sg"
  description = "experimental sg for server/client running in same vcp"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_instance" "simple_server" {
  ami           = "ami-083522e25d3e4d203"
  instance_type = "t4g.micro"

  key_name = "simple_server"

  subnet_id = aws_subnet.simple_subnet.id

  vpc_security_group_ids = [aws_security_group.simple_sg.id]

  user_data = <<-EOF
  #!/bin/bash
  sudo yum update -y
  sudo yum groupinstall "Development Tools" -y
  EOF

  tags = {
    Name = "EC2 Instance Simple Server"
  }
}

resource "aws_instance" "simple_client" {
  ami           = "ami-083522e25d3e4d203"
  instance_type = "t4g.nano"

  key_name = "simple_client"

  subnet_id = aws_subnet.simple_subnet.id

  vpc_security_group_ids = [aws_security_group.simple_sg.id]

  user_data = <<-EOF
  #!/bin/bash
  sudo yum update -y
  sudo yum groupinstall "Development Tools" -y
  EOF

  tags = {
    Name = "EC2 Instance Simple Client"
  }
}

