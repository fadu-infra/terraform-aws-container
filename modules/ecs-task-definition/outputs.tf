################################################################################
# Container Definition
################################################################################

output "container_definitions" {
  description = "The container definitions JSON string"
  value       = local.container_definitions
}

################################################################################
# Task Definition
################################################################################

output "task_definition_family" {
  description = "The unique name of the task definition"
  value       = aws_ecs_task_definition.this.family
}

output "task_definition_arn" {
  description = "Full ARN of the Task Definition (including both `family` and `revision`)"
  value       = aws_ecs_task_definition.this.arn
}

output "task_definition_revision" {
  description = "Revision of the task in a particular family"
  value       = aws_ecs_task_definition.this.revision
}

output "network_mode" {
  description = "The network mode of the ECS task definition."
  value       = aws_ecs_task_definition.this.network_mode
}
