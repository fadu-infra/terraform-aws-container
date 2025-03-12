################################################################################
# Service - IAM Role
################################################################################

locals {
  iam_role_name = try(coalesce(var.iam_role_name, var.name), "")

  # Role is not required if task definition uses `awsvpc` network mode or if a load balancer is not used
  needs_iam_role  = var.network_mode != "awsvpc" && length(var.load_balancer) > 0
  create_iam_role = var.create && var.create_iam_role && local.needs_iam_role
  iam_role_arn    = local.needs_iam_role ? try(aws_iam_role.service[0].arn, var.iam_role_arn) : null
}

data "aws_iam_policy_document" "service_assume" {
  count = local.create_iam_role ? 1 : 0

  statement {
    sid     = "ECSServiceAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "service" {
  count = local.create_iam_role ? 1 : 0

  name        = var.iam_role_use_name_prefix ? null : local.iam_role_name
  name_prefix = var.iam_role_use_name_prefix ? "${local.iam_role_name}-" : null
  path        = var.iam_role_path
  description = var.iam_role_description

  assume_role_policy    = data.aws_iam_policy_document.service_assume[0].json
  permissions_boundary  = var.iam_role_permissions_boundary
  force_detach_policies = true

  tags = merge(
    {
      "Name" = local.metadata.name
    },
    var.iam_role_tags,
    var.tags,
    local.module_tags
  )
}

data "aws_iam_policy_document" "service" {
  count = local.create_iam_role ? 1 : 0

  statement {
    sid       = "ECSService"
    resources = ["*"]

    actions = [
      "ec2:Describe*",
      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:Describe*",
      "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
      "elasticloadbalancing:RegisterTargets"
    ]
  }

  dynamic "statement" {
    for_each = var.iam_role_statements

    content {
      sid           = try(statement.value.sid, null)
      actions       = try(statement.value.actions, null)
      not_actions   = try(statement.value.not_actions, null)
      effect        = try(statement.value.effect, null)
      resources     = try(statement.value.resources, null)
      not_resources = try(statement.value.not_resources, null)

      dynamic "principals" {
        for_each = try(statement.value.principals, [])

        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = try(statement.value.not_principals, [])

        content {
          type        = not_principals.value.type
          identifiers = not_principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = try(statement.value.conditions, [])

        content {
          test     = condition.value.test
          values   = condition.value.values
          variable = condition.value.variable
        }
      }
    }
  }
}

resource "aws_iam_policy" "service" {
  count = local.create_iam_role ? 1 : 0

  name        = var.iam_role_use_name_prefix ? null : local.iam_role_name
  name_prefix = var.iam_role_use_name_prefix ? "${local.iam_role_name}-" : null
  description = coalesce(var.iam_role_description, "ECS service policy that allows Amazon ECS to make calls to your load balancer on your behalf")
  policy      = data.aws_iam_policy_document.service[0].json

  tags = merge(
    {
      "Name" = local.metadata.name
    },
    var.iam_role_tags,
    var.tags,
    local.module_tags
  )
}

resource "aws_iam_role_policy_attachment" "service" {
  count = local.create_iam_role ? 1 : 0

  role       = aws_iam_role.service[0].name
  policy_arn = aws_iam_policy.service[0].arn
}

################################################################################
# Task Execution - IAM Role
################################################################################

locals {
  task_exec_iam_role_name   = try(coalesce(var.task_exec_iam_role_name, var.name), "")
  create_task_exec_iam_role = local.create_task_definition && var.create_task_exec_iam_role
  create_task_exec_policy   = local.create_task_exec_iam_role && var.create_task_exec_policy
}

data "aws_iam_policy_document" "task_exec_assume" {
  count = local.create_task_exec_iam_role ? 1 : 0

  statement {
    sid     = "ECSTaskExecutionAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "task_exec" {
  count = local.create_task_exec_iam_role ? 1 : 0

  name        = var.task_exec_iam_role_use_name_prefix ? null : local.task_exec_iam_role_name
  name_prefix = var.task_exec_iam_role_use_name_prefix ? "${local.task_exec_iam_role_name}-" : null
  path        = var.task_exec_iam_role_path
  description = coalesce(var.task_exec_iam_role_description, "Task execution role for ${local.task_exec_iam_role_name}")

  assume_role_policy    = data.aws_iam_policy_document.task_exec_assume[0].json
  max_session_duration  = var.task_exec_iam_role_max_session_duration
  permissions_boundary  = var.task_exec_iam_role_permissions_boundary
  force_detach_policies = true

  tags = merge(
    {
      "Name" = local.metadata.name
    },
    var.task_exec_iam_role_tags,
    var.tags,
    local.module_tags
  )
}

resource "aws_iam_role_policy_attachment" "task_exec_additional" {
  for_each = { for k, v in var.task_exec_iam_role_policies : k => v if local.create_task_exec_iam_role }

  role       = aws_iam_role.task_exec[0].name
  policy_arn = each.value
}

data "aws_iam_policy_document" "task_exec" {
  count = local.create_task_exec_policy ? 1 : 0

  statement {
    sid = "Logs"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["*"]
  }

  statement {
    sid = "ECR"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
    ]
    resources = ["*"]
  }

  dynamic "statement" {
    for_each = length(var.task_exec_ssm_param_arns) > 0 ? [1] : []

    content {
      sid       = "GetSSMParams"
      actions   = ["ssm:GetParameters"]
      resources = var.task_exec_ssm_param_arns
    }
  }

  dynamic "statement" {
    for_each = length(var.task_exec_secret_arns) > 0 ? [1] : []

    content {
      sid       = "GetSecrets"
      actions   = ["secretsmanager:GetSecretValue"]
      resources = var.task_exec_secret_arns
    }
  }

  dynamic "statement" {
    for_each = var.task_exec_iam_statements

    content {
      sid           = try(statement.value.sid, null)
      actions       = try(statement.value.actions, null)
      not_actions   = try(statement.value.not_actions, null)
      effect        = try(statement.value.effect, null)
      resources     = try(statement.value.resources, null)
      not_resources = try(statement.value.not_resources, null)

      dynamic "principals" {
        for_each = try(statement.value.principals, [])

        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = try(statement.value.not_principals, [])

        content {
          type        = not_principals.value.type
          identifiers = not_principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = try(statement.value.conditions, [])

        content {
          test     = condition.value.test
          values   = condition.value.values
          variable = condition.value.variable
        }
      }
    }
  }
}

resource "aws_iam_policy" "task_exec" {
  count = local.create_task_exec_policy ? 1 : 0

  name        = var.task_exec_iam_role_use_name_prefix ? null : local.task_exec_iam_role_name
  name_prefix = var.task_exec_iam_role_use_name_prefix ? "${local.task_exec_iam_role_name}-" : null
  description = coalesce(var.task_exec_iam_role_description, "Task execution role IAM policy")
  policy      = data.aws_iam_policy_document.task_exec[0].json
  path        = var.task_exec_iam_policy_path
  tags = merge(
    {
      "Name" = local.metadata.name
    },
    var.tags,
    local.module_tags,
    var.task_exec_iam_role_tags
  )
}

resource "aws_iam_role_policy_attachment" "task_exec" {
  count = local.create_task_exec_policy ? 1 : 0

  role       = aws_iam_role.task_exec[0].name
  policy_arn = aws_iam_policy.task_exec[0].arn
}

################################################################################
# Tasks - IAM Role
################################################################################

locals {
  tasks_iam_role_name   = try(coalesce(var.tasks_iam_role_name, var.name), "")
  create_tasks_iam_role = local.create_task_definition && var.create_tasks_iam_role
}

data "aws_iam_policy_document" "tasks_assume" {
  count = local.create_tasks_iam_role ? 1 : 0

  statement {
    sid     = "ECSTasksAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:${local.partition}:ecs:${local.region}:${local.account_id}:*"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.account_id]
    }
  }
}

resource "aws_iam_role" "tasks" {
  count = local.create_tasks_iam_role ? 1 : 0

  name        = var.tasks_iam_role_use_name_prefix ? null : local.tasks_iam_role_name
  name_prefix = var.tasks_iam_role_use_name_prefix ? "${local.tasks_iam_role_name}-" : null
  path        = var.tasks_iam_role_path
  description = var.tasks_iam_role_description

  assume_role_policy    = data.aws_iam_policy_document.tasks_assume[0].json
  permissions_boundary  = var.tasks_iam_role_permissions_boundary
  force_detach_policies = true

  tags = merge(
    {
      "Name" = local.metadata.name
    },
    var.tasks_iam_role_tags,
    var.tags,
    local.module_tags
  )
}

resource "aws_iam_role_policy_attachment" "tasks" {
  for_each = { for k, v in var.tasks_iam_role_policies : k => v if local.create_tasks_iam_role }

  role       = aws_iam_role.tasks[0].name
  policy_arn = each.value
}

data "aws_iam_policy_document" "tasks" {
  count = local.create_tasks_iam_role && (length(var.tasks_iam_role_statements) > 0 || var.enable_execute_command) ? 1 : 0

  dynamic "statement" {
    for_each = var.enable_execute_command ? [1] : []

    content {
      sid = "ECSExec"
      actions = [
        "ssmmessages:CreateControlChannel",
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:OpenDataChannel",
      ]
      resources = ["*"]
    }
  }

  dynamic "statement" {
    for_each = var.tasks_iam_role_statements

    content {
      sid           = try(statement.value.sid, null)
      actions       = try(statement.value.actions, null)
      not_actions   = try(statement.value.not_actions, null)
      effect        = try(statement.value.effect, null)
      resources     = try(statement.value.resources, null)
      not_resources = try(statement.value.not_resources, null)

      dynamic "principals" {
        for_each = try(statement.value.principals, [])

        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = try(statement.value.not_principals, [])

        content {
          type        = not_principals.value.type
          identifiers = not_principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = try(statement.value.conditions, [])

        content {
          test     = condition.value.test
          values   = condition.value.values
          variable = condition.value.variable
        }
      }
    }
  }
}

resource "aws_iam_role_policy" "tasks" {
  count = local.create_tasks_iam_role && (length(var.tasks_iam_role_statements) > 0 || var.enable_execute_command) ? 1 : 0

  name        = var.tasks_iam_role_use_name_prefix ? null : local.tasks_iam_role_name
  name_prefix = var.tasks_iam_role_use_name_prefix ? "${local.tasks_iam_role_name}-" : null
  policy      = data.aws_iam_policy_document.tasks[0].json
  role        = aws_iam_role.tasks[0].id
}
