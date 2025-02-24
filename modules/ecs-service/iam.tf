locals {
  # ECS Service Role & Policies
  ecs_service_role_name = "${var.common_name_prefix}-EcsServiceRole"
  ecs_service_policies = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole",
    "arn:aws:iam::aws:policy/service-role/AmazonECSInfrastructureRolePolicyForVolumes"
  ]

  # ECS Task Execution Role & Policies
  ecs_task_role_name = "${var.common_name_prefix}-EcsTaskExecutionRole"
  ecs_task_policies = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
}

# Function to create IAM Role
resource "aws_iam_role" "this" {
  for_each = {
    ecs_service = {
      name        = local.ecs_service_role_name
      description = "Allows ECS services to call AWS services on your behalf"
      principal   = "ecs.amazonaws.com"
    }
    ecs_task = {
      name        = local.ecs_task_role_name
      description = "Allows ECS tasks to call AWS services on your behalf"
      principal   = "ecs-tasks.amazonaws.com"
    }
  }

  name        = each.value.name
  description = each.value.description

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = each.value.principal
      }
    }]
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Function to attach policies
resource "aws_iam_role_policy_attachment" "this" {
  for_each = merge(
    { for index, policy in local.ecs_service_policies : "service-${index}" => {
      role       = aws_iam_role.this["ecs_service"].name
      policy_arn = policy
      }
    },
    { for index, policy in local.ecs_task_policies : "task-${index}" => {
      role       = aws_iam_role.this["ecs_task"].name
      policy_arn = policy
      }
    }
  )

  role       = each.value.role
  policy_arn = each.value.policy_arn
}
