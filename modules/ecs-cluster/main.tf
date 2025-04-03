################################################################################
# Cluster
################################################################################

locals {
  metadata = {
    package = "terraform-aws-container"
    version = trimspace(file("${path.module}/../../VERSION"))
    module  = basename(path.module)
    name    = var.name
  }
  module_tags = {
    "module.terraform.io/name"    = "${local.metadata.package}/${local.metadata.module}"
    "module.terraform.io/version" = local.metadata.version
  }

  execute_command_configuration = {
    kms_key_id = null
    logging    = "OVERRIDE"
    log_configuration = {
      cloud_watch_log_group_name = try(aws_cloudwatch_log_group.this[0].name, null)
    }
  }
}

resource "aws_ecs_cluster" "this" {
  name = var.name

  dynamic "configuration" {
    for_each = length(var.cluster_configuration) > 0 ? var.cluster_configuration : []

    content {
      dynamic "execute_command_configuration" {
        for_each = var.cloudwatch_log_group.create ? [merge(local.execute_command_configuration, configuration.value.execute_command_configuration)] : [configuration.value.execute_command_configuration]

        content {
          kms_key_id = execute_command_configuration.value.kms_key_id
          logging    = execute_command_configuration.value.logging

          dynamic "log_configuration" {
            for_each = [execute_command_configuration.value.log_configuration]

            content {
              cloud_watch_encryption_enabled = log_configuration.value.cloud_watch_encryption_enabled
              cloud_watch_log_group_name     = log_configuration.value.cloud_watch_log_group_name
              s3_bucket_name                 = log_configuration.value.s3_bucket_name
              s3_bucket_encryption_enabled   = log_configuration.value.s3_bucket_encryption_enabled
              s3_key_prefix                  = log_configuration.value.s3_key_prefix
            }
          }
        }
      }
    }
  }

  dynamic "service_connect_defaults" {
    for_each = var.cluster_service_connect_defaults

    content {
      namespace = service_connect_defaults.value.namespace
    }
  }

  dynamic "setting" {
    for_each = var.cluster_settings

    content {
      name  = setting.value.name
      value = setting.value.value
    }
  }

  tags = merge(
    {
      "Name" = var.name
    },
    local.module_tags,
    var.tags,
  )
}

################################################################################
# CloudWatch Log Group
################################################################################

resource "aws_cloudwatch_log_group" "this" {
  count = var.cloudwatch_log_group.create ? 1 : 0

  name              = coalesce(var.cloudwatch_log_group.name, "/aws/ecs/${var.name}")
  retention_in_days = var.cloudwatch_log_group.retention_in_days
  kms_key_id        = var.cloudwatch_log_group.kms_key_id

  tags = merge(
    {
      "Name" = local.metadata.name
    },
    var.cloudwatch_log_group.tags,
    var.tags,
    local.module_tags
  )
}

################################################################################
# Cluster Capacity Providers
################################################################################

locals {
  selected_capacity_providers = merge(var.fargate_capacity_providers, var.autoscaling_capacity_provider)
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  count = length(local.selected_capacity_providers) > 0 ? 1 : 0

  cluster_name       = aws_ecs_cluster.this.name
  capacity_providers = distinct([for provider in local.selected_capacity_providers : provider.name])

  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/cluster-capacity-providers.html#capacity-providers-considerations
  dynamic "default_capacity_provider_strategy" {
    for_each = local.selected_capacity_providers
    iterator = strategy

    content {
      capacity_provider = strategy.value.name
      base              = strategy.value.default_capacity_provider_strategy.base
      weight            = strategy.value.default_capacity_provider_strategy.weight
    }
  }

  depends_on = [
    aws_ecs_capacity_provider.this
  ]
}

################################################################################
# Capacity Provider - Autoscaling Group(s)
################################################################################

resource "aws_ecs_capacity_provider" "this" {
  count = length(var.autoscaling_capacity_provider) > 0 ? 1 : 0

  name = var.autoscaling_capacity_provider.name

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.this[0].arn
    # When you use managed termination protection, you must also use managed scaling otherwise managed termination protection won't work
    managed_termination_protection = var.autoscaling_capacity_provider.managed_termination_protection

    dynamic "managed_scaling" {
      for_each = [var.autoscaling_capacity_provider.managed_scaling]

      content {
        instance_warmup_period    = managed_scaling.value.instance_warmup_period
        maximum_scaling_step_size = managed_scaling.value.maximum_scaling_step_size
        minimum_scaling_step_size = managed_scaling.value.minimum_scaling_step_size
        status                    = managed_scaling.value.status
        target_capacity           = managed_scaling.value.target_capacity
      }
    }
  }

  tags = merge(
    {
      "Name" = local.metadata.name
    },
    var.tags,
    local.module_tags
  )
}
