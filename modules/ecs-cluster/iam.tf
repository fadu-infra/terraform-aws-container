locals {
  ecs_instance_role_name    = "${var.name}-Ec2InstanceRole"
  ecs_instance_profile_name = "${var.name}-Ec2InstanceProfile"
  ecs_instance_policies = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  ecs_task_execution_role_name = "${var.name}-EcsTaskExecutionRole"
  ecs_task_execution_policies = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
  ]
}

################################################################################
# ECS Instance Role
################################################################################

resource "aws_iam_role" "ecs_instance" {
  count = var.autoscaling_capacity_provider != null ? 1 : 0

  name        = local.ecs_instance_role_name
  description = "Allows EC2 instances to call AWS services on your behalf"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = merge(
    {
      "Name" = local.metadata.name
    },
    var.tags,
    local.module_tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "ecs_instance" {
  count = var.autoscaling_capacity_provider != null ? length(local.ecs_instance_policies) : 0

  role       = aws_iam_role.ecs_instance[0].name
  policy_arn = local.ecs_instance_policies[count.index]
}


resource "aws_iam_instance_profile" "ecs_instance" {
  count = var.autoscaling_capacity_provider != null ? 1 : 0

  name = local.ecs_instance_profile_name
  role = aws_iam_role.ecs_instance[0].name

  lifecycle {
    create_before_destroy = true
  }
}

################################################################################
# Task Execution Role
################################################################################

resource "aws_iam_role" "ecs_task_execution" {
  name = local.ecs_task_execution_role_name
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

  tags = merge(
    {
      "Name" = local.metadata.name
    },
    var.tags,
    local.module_tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  count = length(local.ecs_task_execution_policies)

  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = local.ecs_task_execution_policies[count.index]
}
