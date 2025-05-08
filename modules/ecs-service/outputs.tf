################################################################################
# Service
################################################################################

output "id" {
  description = "ARN that identifies the service"
  value       = try(aws_ecs_service.this.id, null)
}

output "name" {
  description = "Name of the service"
  value       = try(aws_ecs_service.this.name, null)
}
