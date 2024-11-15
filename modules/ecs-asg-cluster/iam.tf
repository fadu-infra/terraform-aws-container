locals {
  services = [
    {
      # Allow EC2 instance to register as ECS cluster member, fetch ECR images, write logs to CloudWatch
      role_name  = "${local.common_name_prefix}-Ec2InstanceRole",
      identifier = "ec2.amazonaws.com",
      policies = [
        "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
        "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
        "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
      ]
    },
    {
      # Allow ECS service to interact with LoadBalancers
      role_name  = "${local.common_name_prefix}-EcsServiceRole",
      identifier = "ecs.amazonaws.com",
      policies = [
        "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole",
        "arn:aws:iam::aws:policy/service-role/AmazonECSInfrastructureRolePolicyForVolumes"
      ]
    },
    {
      # Allow ECS tasks to write logs to CloudWatch
      role_name  = "${local.common_name_prefix}-EcsTaskExecutionRole",
      identifier = "ecs-tasks.amazonaws.com",
      policies = [
        "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
        "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      ]
    },
    {
      # Allow DLM to manage EBS snapshots
      role_name  = "${local.common_name_prefix}-DlmServiceRole",
      identifier = "dlm.amazonaws.com",
      policies = [
        "arn:aws:iam::aws:policy/service-role/AWSDataLifecycleManagerServiceRole"
      ]
    }
  ]
}

data "aws_iam_policy_document" "assume_role_policies" {
  for_each = { for svc in local.services : svc.role_name => svc }

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = [each.value.identifier]
    }
  }
}

resource "aws_iam_role" "service_roles" {
  for_each = { for svc in local.services : svc.role_name => svc }

  name                = each.value.role_name
  assume_role_policy  = data.aws_iam_policy_document.assume_role_policies[each.key].json
  tags                = local.tags
}

resource "aws_iam_role_policy_attachment" "service_role_policies" {
  for_each = {
    for policy in flatten([
      for svc in local.services : [
        for policy_arn in svc.policies : {
          role_name   = svc.role_name
          policy_arn  = policy_arn
        }
      ]
    ]) : "${policy.role_name}-${policy.policy_arn}" => policy
  }

  role       = aws_iam_role.service_roles[each.value.role_name].name
  policy_arn = each.value.policy_arn
}

resource "aws_iam_instance_profile" "ecs_node" {
  name = "${local.common_name_prefix}-Ec2InstanceProfile"
  role = aws_iam_role.service_roles["${local.common_name_prefix}-Ec2InstanceRole"].name
}
