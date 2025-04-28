################################################################################
# Cluster
################################################################################

output "arn" {
  description = "ARN that identifies the cluster"
  value       = aws_ecs_cluster.this.arn
}

output "id" {
  description = "ID that identifies the cluster"
  value       = aws_ecs_cluster.this.id
}

output "name" {
  description = "Name that identifies the cluster"
  value       = aws_ecs_cluster.this.name
}

output "execute_command_log_group_name" {
  description = "The CloudWatch log group name specified for Execute Command logging. Null if logging is not OVERRIDE or not configured."
  value       = var.logging == "OVERRIDE" && var.log_configuration != null ? var.log_configuration.cloud_watch_log_group_name : null
}

output "service_connect_defaults_namespace_arn" {
  description = "The ARN of the default namespace for Service Connect. Null if not configured."
  value       = var.service_discovery_namespace_arn != null ? one(aws_ecs_cluster.this.service_connect_defaults[*].namespace) : null
}

################################################################################
# Cluster Capacity Providers
################################################################################

output "cluster_capacity_providers" {
  description = "Map of cluster capacity providers attributes"
  value       = { for k, v in aws_ecs_cluster_capacity_providers.this : v.id => v }
}

################################################################################
# Capacity Provider - Autoscaling Group(s)
################################################################################

output "autoscaling_capacity_provider" {
  description = "Map of autoscaling capacity provider created and their attributes"
  value       = aws_ecs_capacity_provider.this
}

################################################################################
# IAM Role
################################################################################

output "ecs_instance_role_name" {
  description = "Service IAM role name"
  value       = try(aws_iam_role.ecs_instance[0].name, null)
}

output "ecs_instance_role_arn" {
  description = "Service IAM role ARN"
  value       = try(aws_iam_role.ecs_instance[0].arn, null)
}

output "ecs_instance_role_unique_id" {
  description = "Stable and unique string identifying the service IAM role"
  value       = try(aws_iam_role.ecs_instance[0].unique_id, null)
}

output "ecs_task_execution_role_name" {
  description = "Service IAM role name"
  value       = try(aws_iam_role.ecs_task_execution.name, null)
}

output "ecs_task_execution_role_arn" {
  description = "Service IAM role ARN"
  value       = aws_iam_role.ecs_task_execution.arn
}

output "ecs_task_execution_role_unique_id" {
  description = "Stable and unique string identifying the service IAM role"
  value       = aws_iam_role.ecs_task_execution.unique_id
}
