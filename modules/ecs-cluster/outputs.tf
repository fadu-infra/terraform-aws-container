output "capacity_provider" {
  value = {
    name = aws_ecs_capacity_provider.asg.name
  }
  description = "The name of the capacity provider, which is the same as the name for ASG."
}

output "ecs_cluster_details" {
  value = {
    arn  = aws_ecs_cluster.default.arn
    id   = aws_ecs_cluster.default.id
    name = aws_ecs_cluster.default.name
  }
  description = "Details of the ECS cluster including ARN, ID, and name."
}

output "ecs_service_role" {
  value = {
    name = aws_iam_role.ecs_service.name
    arn  = aws_iam_role.ecs_service.arn
  }
  description = "The name and ARN of the ECS service role."
}

output "ecs_task_execution_role" {
  value = {
    name = aws_iam_role.ecs_task.name
    arn  = aws_iam_role.ecs_task.arn
  }
  description = "The name and ARN of the ECS default task execution role."
}

output "iam_instance_profile" {
  value = {
    arn  = aws_iam_instance_profile.ecs_instance.arn
    name = aws_iam_instance_profile.ecs_instance.name
  }
  description = "The ARN and name of the IAM instance profile."
}

output "iam_instance_role" {
  value = {
    arn  = aws_iam_role.ecs_instance.arn
    name = aws_iam_role.ecs_instance.name
  }
  description = "The ARN and name of the IAM instance role."
}

output "security_group" {
  value = {
    id   = aws_security_group.ecs_nodes.id
    name = aws_security_group.ecs_nodes.name
  }
  description = "The ID and name of the ECS nodes security group."
}
