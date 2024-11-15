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
    name = aws_iam_role.service_roles["${local.common_name_prefix}-EcsServiceRole"].name
    arn  = aws_iam_role.service_roles["${local.common_name_prefix}-EcsServiceRole"].arn
  }
  description = "The name and ARN of the ECS service role."
}

output "ecs_task_execution_role" {
  value = {
    name = aws_iam_role.service_roles["${local.common_name_prefix}-EcsTaskExecutionRole"].name
    arn  = aws_iam_role.service_roles["${local.common_name_prefix}-EcsTaskExecutionRole"].arn
  }
  description = "The name and ARN of the ECS default task execution role."
}

output "iam_instance_profile" {
  value = {
    arn  = aws_iam_instance_profile.ecs_node.arn
    name = aws_iam_instance_profile.ecs_node.name
  }
  description = "The ARN and name of the IAM instance profile."
}

output "iam_instance_role" {
  value = {
    arn  = aws_iam_role.service_roles["${local.common_name_prefix}-Ec2InstanceRole"].arn
    name = aws_iam_role.service_roles["${local.common_name_prefix}-Ec2InstanceRole"].name
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

output "dlm_service_role" {
  description = "The name and ARN of the DLM service role."
  value = {
    name = module.ecs_cluster.dlm_service_role_name
    arn  = module.ecs_cluster.dlm_service_role_arn
  }
}