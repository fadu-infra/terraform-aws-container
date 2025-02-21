output "capacity_provider" {
  value = {
    name = aws_ecs_capacity_provider.this.name
  }
  description = "The name of the capacity provider, which is the same as the name for ASG."
}

output "ecs_cluster_details" {
  value = {
    arn  = aws_ecs_cluster.this.arn
    id   = aws_ecs_cluster.this.id
    name = aws_ecs_cluster.this.name
  }
  description = "Details of the ECS cluster including ARN, ID, and name."
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
