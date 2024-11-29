# Common IAM policy definitions
locals {
  # ECS Instance Role & Policies
  ecs_instance_role_name = "${local.common_name_prefix}-Ec2InstanceRole"
  ecs_instance_policies = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  ]

  # ECS Service Role & Policies
  ecs_service_role_name = "${local.common_name_prefix}-EcsServiceRole"
  ecs_service_policies = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole",
    "arn:aws:iam::aws:policy/service-role/AmazonECSInfrastructureRolePolicyForVolumes"
  ]

  # ECS Task Role & Policies
  ecs_task_role_name = "${local.common_name_prefix}-EcsTaskExecutionRole"
  ecs_task_policies = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  # DLM Service Role & Policies
  dlm_service_role_name = "${local.common_name_prefix}-DlmServiceRole"
  dlm_service_policies = [
    "arn:aws:iam::aws:policy/service-role/AWSDataLifecycleManagerServiceRole"
  ]
}

# ECS Instance Role
resource "aws_iam_role" "ecs_instance" {
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

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "ecs_instance" {
  count = length(local.ecs_instance_policies)

  role       = aws_iam_role.ecs_instance.name
  policy_arn = local.ecs_instance_policies[count.index]
}

resource "aws_iam_instance_profile" "ecs_instance" {
  name = "${local.ecs_instance_role_name}-profile"
  role = aws_iam_role.ecs_instance.name

  lifecycle {
    create_before_destroy = true
  }
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

# ECS Task Role
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

# DLM Service Role
resource "aws_iam_role" "dlm_service" {
  name        = local.dlm_service_role_name
  description = "Allows DLM to manage EBS snapshots"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "dlm.amazonaws.com"
      }
    }]
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "dlm_service" {
  count = length(local.dlm_service_policies)

  role       = aws_iam_role.dlm_service.name
  policy_arn = local.dlm_service_policies[count.index]
}
