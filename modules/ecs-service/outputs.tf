output "ecs_service_role" {
  value = {
    name = aws_iam_role.this["ecs_service"].name
    arn  = aws_iam_role.this["ecs_service"].arn
  }
  description = "The name and ARN of the ECS service role."
}

output "ecs_task_execution_role" {
  value = {
    name = aws_iam_role.this["ecs_task"].name
    arn  = aws_iam_role.this["ecs_task"].arn
  }
  description = "The name and ARN of the ECS default task execution role."
}
