locals {
  iam_roles = {
    ec2_instance = {
      name        = format("%s-Ec2InstanceRole", local.common_name_prefix)
      principal  = "ec2.amazonaws.com"
      description = "Allows EC2 instances to call AWS services on your behalf"
      policies = [
        "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
        "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
        "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
      ]
      create_instance_profile = true
    }

    ecs_service = {
      name        = format("%s-EcsServiceRole", local.common_name_prefix)
      principal  = "ecs.amazonaws.com"
      description = "Allows ECS services to call AWS services on your behalf"
      policies = [
        "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole",
        "arn:aws:iam::aws:policy/service-role/AmazonECSInfrastructureRolePolicyForVolumes"
      ]
    }

    ecs_task = {
      name        = format("%s-EcsTaskExecutionRole", local.common_name_prefix)
      principal  = "ecs-tasks.amazonaws.com"
      description = "Allows ECS tasks to call AWS services on your behalf"
      policies = [
        "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
        "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      ]
    }

    dlm_service = {
      name        = format("%s-DlmServiceRole", local.common_name_prefix)
      principal  = "dlm.amazonaws.com"
      description = "Allows DLM to manage EBS snapshots"
      policies = [
        "arn:aws:iam::aws:policy/service-role/AWSDataLifecycleManagerServiceRole"
      ]
    }
  }

  role_policy_attachments = merge([
    for role_key, role in local.iam_roles : {
      for policy_arn in role.policies :
      "${role.name}:${policy_arn}" => {
        role_name  = role.name
        policy_arn = policy_arn
      }
    }
  ])
}

resource "aws_iam_role" "roles" {
  for_each = local.iam_roles

  name        = each.value.name
  description = each.value.description
  tags        = local.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = each.value.principal
        }
      }
    ]
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

resource "aws_iam_role_policy_attachment" "role_policies" {
  for_each = local.role_policy_attachments

  role       = each.value.role_name
  policy_arn = each.value.policy_arn

  depends_on = [aws_iam_role.roles]
}

resource "aws_iam_instance_profile" "profile" {
  for_each = {
    for k, v in local.iam_roles : k => v
    if try(v.create_instance_profile, false)
  }

  name = "${each.value.name}-profile"
  role = aws_iam_role.roles[each.key].name

  lifecycle {
    create_before_destroy = true
  }
}