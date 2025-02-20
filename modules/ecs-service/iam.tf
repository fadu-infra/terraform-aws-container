locals { # ECS Service Role & Policies
  ecs_service_role_name = "${local.common_name_prefix}-EcsServiceRole"
  ecs_service_policies = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole",
    "arn:aws:iam::aws:policy/service-role/AmazonECSInfrastructureRolePolicyForVolumes"
  ]

  # ECS Task Execution Role & Policies
  ecs_task_role_name = "${local.common_name_prefix}-EcsTaskExecutionRole"
  ecs_task_policies = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
}

# ECS Service Role
resource "aws_iam_role" "ecs_service" {
  name        = local.ecs_service_role_name
  description = "Allows ECS services to call AWS services on your behalf"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs.amazonaws.com"
      }
    }]
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "ecs_service" {
  count = length(local.ecs_service_policies)

  role       = aws_iam_role.ecs_service.name
  policy_arn = local.ecs_service_policies[count.index]
}

# ECS Task Execution Role
resource "aws_iam_role" "ecs_task" {
  name        = local.ecs_task_role_name
  description = "Allows ECS tasks to call AWS services on your behalf"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task" {
  count = length(local.ecs_task_policies)

  role       = aws_iam_role.ecs_task.name
  policy_arn = local.ecs_task_policies[count.index]
}
