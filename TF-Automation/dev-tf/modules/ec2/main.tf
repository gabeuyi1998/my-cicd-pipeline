resource "aws_instance" "app_server" {
  ami                  = var.ami
  instance_type        = var.instance_type
  subnet_id            = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids
  iam_instance_profile = var.iam_instance_profile_name
  tags = {
    Name        = "${var.environment}-app-server"
    Environment = var.environment
  }
}

output "instance_id" {
  value = aws_instance.app_server.id
}

output "public_ip" {
  value = aws_instance.app_server.public_ip
}