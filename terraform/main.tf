resource "aws_instance" "web_app" {
  ami  = "ami-053a45fff0a704a47"
  type = "t2.micro"

  tags = {
    Name = "Web App EC2 Instance"
  }
}

