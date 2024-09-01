output "ecs_service_url" {
  value = aws_ecs_service.service.network_configuration[0].assign_public_ip
}