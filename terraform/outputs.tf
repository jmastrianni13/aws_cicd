output "ec2_simple_server_ip" {
  value     = aws_instance.simple_server.public_ip
  sensitive = true
}

