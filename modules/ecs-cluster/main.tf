resource "aws_ecs_cluster" "this" {
  name = local.name
  tags = local.tags
}

# ECS Cluster Capacity Providers
resource "aws_ecs_capacity_provider" "this" {
  name = aws_autoscaling_group.this.name

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.this.arn
    managed_termination_protection = local.protect_from_scale_in ? "ENABLED" : "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = 10
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = local.target_capacity
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = [aws_ecs_capacity_provider.this.name]

  dynamic "default_capacity_provider_strategy" {
    for_each = var.enabled_default_capacity_provider ? [1] : []
    content {
      base              = 1
      weight            = 100
      capacity_provider = aws_ecs_capacity_provider.this.name
    }
  }
}

# Common IAM policy definitions
locals {
  # ECS Instance Role & Policies
  ecs_instance_role_name = "${local.common_name_prefix}-Ec2InstanceRole"
  ecs_instance_policies = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  ]
}

# ECS Instance Role
resource "aws_iam_role" "this" {
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

resource "aws_iam_role_policy_attachment" "this" {
  count = length(local.ecs_instance_policies)

  role       = aws_iam_role.this.name
  policy_arn = local.ecs_instance_policies[count.index]
}

resource "aws_iam_instance_profile" "this" {
  name = "${local.ecs_instance_role_name}-profile"
  role = aws_iam_role.this.name

  lifecycle {
    create_before_destroy = true
  }
}
