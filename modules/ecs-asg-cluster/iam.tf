locals {
  # Common IAM policies by service
  ecs_policies = {
    instance = [
      "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
      "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
      "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
    ]
    service = [
      "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole",
      "arn:aws:iam::aws:policy/service-role/AmazonECSInfrastructureRolePolicyForVolumes"
    ]
    task = [
      "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
      "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    ]
  }

  # Role definitions
  service_roles = {
    ec2_instance = {
      name                    = "${local.common_name_prefix}-Ec2InstanceRole"
      principal               = "ec2.amazonaws.com"
      description             = "Allows EC2 instances to call AWS services on your behalf"
      policies                = local.ecs_policies.instance
      create_instance_profile = true
    }
    ecs_service = {
      name        = "${local.common_name_prefix}-EcsServiceRole"
      principal   = "ecs.amazonaws.com"
      description = "Allows ECS services to call AWS services on your behalf"
      policies    = local.ecs_policies.service
    }
    ecs_task = {
      name        = "${local.common_name_prefix}-EcsTaskExecutionRole"
      principal   = "ecs-tasks.amazonaws.com"
      description = "Allows ECS tasks to call AWS services on your behalf"
      policies    = local.ecs_policies.task
    }
    dlm_service = {
      name        = "${local.common_name_prefix}-DlmServiceRole"
      principal   = "dlm.amazonaws.com"
      description = "Allows DLM to manage EBS snapshots"
      policies    = ["arn:aws:iam::aws:policy/service-role/AWSDataLifecycleManagerServiceRole"]
    }
  }

  # Simplified policy attachment mapping
  policy_attachments = {
    for role_key, role in local.service_roles :
    role.name => {
      role_name = role.name
      policies  = role.policies
    }
  }
}

resource "aws_iam_role" "service_roles" {
  for_each = local.service_roles

  name        = each.value.name
  description = each.value.description
  tags        = local.tags

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

  dynamic "inline_policy" {
    for_each = try(each.value.inline_policies, {})
    content {
      name   = inline_policy.key
      policy = inline_policy.value
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "service_role_policies" {
  for_each = {
    for role_name, role in local.policy_attachments :
    role_name => role.policies[*]
  }

  role       = each.key
  policy_arn = each.value

  depends_on = [aws_iam_role.service_roles]
}

resource "aws_iam_instance_profile" "service_profiles" {
  for_each = {
    for k, v in local.service_roles : k => v
    if try(v.create_instance_profile, false)
  }

  name = "${each.value.name}-profile"
  role = aws_iam_role.service_roles[each.key].name

  lifecycle {
    create_before_destroy = true
  }
}
