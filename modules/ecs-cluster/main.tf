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
}

locals {
  selected_capacity_providers = merge(var.fargate_capacity_providers, var.autoscaling_capacity_provider)
}

################################################################################
# Cluster
################################################################################

resource "aws_ecs_cluster" "this" {
  name = var.name

  setting {
    name  = "containerInsights"
    value = var.container_insights_level
  }

  configuration {
    execute_command_configuration {
      kms_key_id = var.kms_key_id
      logging    = var.logging

      dynamic "log_configuration" {
        for_each = var.logging == "OVERRIDE" ? [var.log_configuration] : []

        content {
          cloud_watch_encryption_enabled = log_configuration.value.cloud_watch_encryption_enabled
          cloud_watch_log_group_name     = log_configuration.value.cloud_watch_log_group_name
        }
      }
    }
  }

  dynamic "service_connect_defaults" {
    for_each = var.service_discovery_namespace_arn != null ? [var.service_discovery_namespace_arn] : []

    content {
      namespace = service_connect_defaults.value
    }
  }
}

################################################################################
# Cluster Capacity Providers
################################################################################

resource "aws_ecs_cluster_capacity_providers" "this" {
  count = length(local.selected_capacity_providers) > 0 ? 1 : 0

  cluster_name       = aws_ecs_cluster.this.name
  capacity_providers = distinct([for provider in local.selected_capacity_providers : provider.name])

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
  for_each = var.autoscaling_capacity_provider

  name = each.value.name

  auto_scaling_group_provider {
    auto_scaling_group_arn         = each.value.autoscaling_group_arn
    managed_draining               = each.value.managed_draining ? "ENABLED" : "DISABLED"
    managed_termination_protection = each.value.managed_termination_protection ? "ENABLED" : "DISABLED"

    dynamic "managed_scaling" {
      for_each = [each.value.managed_scaling]

      content {
        status                    = managed_scaling.value.enabled ? "ENABLED" : "DISABLED"
        instance_warmup_period    = managed_scaling.value.instance_warmup_period
        maximum_scaling_step_size = managed_scaling.value.maximum_scaling_step_size
        minimum_scaling_step_size = managed_scaling.value.minimum_scaling_step_size
        target_capacity           = managed_scaling.value.target_capacity
      }
    }
  }

  tags = merge(
    {
      "Name" = each.value.name
    },
    var.tags,
    local.module_tags
  )
}
