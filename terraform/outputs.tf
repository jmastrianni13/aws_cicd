output "web_app_ip" {
  description = "Public IP address for web app"
  value = aws_instance.web_app.public_ip
}

