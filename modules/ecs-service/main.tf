data "aws_region" "current" {}
data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

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

  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition
  region     = data.aws_region.current.name
}

################################################################################
# Service
################################################################################

locals {
  is_daemon  = var.scheduling_strategy == "DAEMON"
  is_fargate = var.launch_type == "FARGATE"
}

resource "aws_ecs_service" "this" {
  cluster         = var.cluster_arn
  name            = var.name
  task_definition = var.task_definition_arn

  dynamic "alarms" {
    for_each = var.alarms

    content {
      alarm_names = alarms.value.alarm_names
      enable      = alarms.value.enable
      rollback    = alarms.value.rollback
    }
  }

  dynamic "capacity_provider_strategy" {
    for_each = var.capacity_provider_strategy

    content {
      base              = capacity_provider_strategy.value.base
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight            = capacity_provider_strategy.value.weight
    }
  }

  deployment_circuit_breaker {
    enable   = var.deployment_setting.circuit_breaker.enable
    rollback = var.deployment_setting.circuit_breaker.rollback
  }

  deployment_maximum_percent         = local.is_daemon ? null : var.deployment_setting.maximum_percent
  deployment_minimum_healthy_percent = local.is_daemon ? null : var.deployment_setting.minimum_healthy_percent
  desired_count                      = local.is_daemon ? null : var.desired_count
  enable_ecs_managed_tags            = var.enable_ecs_managed_tags
  enable_execute_command             = var.enable_execute_command
  force_new_deployment               = var.force_new_deployment
  health_check_grace_period_seconds  = var.health_check_grace_period_seconds
  iam_role                           = local.iam_role_arn
  launch_type                        = length(var.capacity_provider_strategy) > 0 ? null : var.launch_type

  dynamic "network_configuration" {
    for_each = var.network_mode == "awsvpc" ? [var.network_configuration] : []

    content {
      assign_public_ip = network_configuration.value.assign_public_ip
      security_groups  = network_configuration.value.security_group_ids
      subnets          = network_configuration.value.subnet_ids
    }
  }

  dynamic "ordered_placement_strategy" {
    for_each = var.ordered_placement_strategy

    content {
      field = ordered_placement_strategy.value.field
      type  = ordered_placement_strategy.value.type
    }
  }

  dynamic "placement_constraints" {
    for_each = var.placement_constraints

    content {
      expression = try(placement_constraints.value.expression, null)
      type       = placement_constraints.value.type
    }
  }

  platform_version = local.is_fargate ? var.platform_version : null

  scheduling_strategy = local.is_fargate ? "REPLICA" : var.scheduling_strategy

  dynamic "load_balancer" {
    for_each = var.load_balancers

    content {
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
      elb_name         = try(load_balancer.value.elb_name, null)
      target_group_arn = try(load_balancer.value.target_group_arn, null)
    }
  }

  dynamic "service_connect_configuration" {
    for_each = length(var.service_connect_configuration) > 0 ? [var.service_connect_configuration] : []

    content {
      enabled = service_connect_configuration.value.enabled

      dynamic "log_configuration" {
        for_each = service_connect_configuration.value.log_configuration != null ? [service_connect_configuration.value.log_configuration] : []

        content {
          log_driver = log_configuration.value.log_driver
          options    = log_configuration.value.options

          dynamic "secret_option" {
            for_each = log_configuration.value.secret_option != null ? log_configuration.value.secret_option : []

            content {
              name       = secret_option.value.name
              value_from = secret_option.value.value_from
            }
          }
        }
      }

      namespace = lookup(service_connect_configuration.value, "namespace", null)

      dynamic "service" {
        for_each = service_connect_configuration.value.service != null ? [service_connect_configuration.value.service] : []

        content {
          dynamic "client_alias" {
            for_each = service.value.client_alias != null ? [service.value.client_alias] : []

            content {
              dns_name = client_alias.value.dns_name
              port     = client_alias.value.port
            }
          }

          discovery_name        = service.value.discovery_name
          ingress_port_override = service.value.ingress_port_override
          port_name             = service.value.port_name
        }
      }
    }
  }

  dynamic "service_registries" {
    for_each = length(var.service_discovery_registries) > 0 ? [{ for k, v in var.service_discovery_registries : k => v if !local.is_daemon }] : []

    content {
      container_name = try(service_registries.value.container_name, null)
      container_port = try(service_registries.value.container_port, null)
      port           = try(service_registries.value.port, null)
      registry_arn   = service_registries.value.registry_arn
    }
  }

  triggers = var.triggers

  wait_for_steady_state = var.wait_for_steady_state

  propagate_tags = var.propagate_tags
  tags = merge(
    {
      "Name" = local.metadata.name
    },
    var.service_tags,
    var.tags,
    local.module_tags
  )

  timeouts {
    create = try(var.timeouts.create, null)
    update = try(var.timeouts.update, null)
    delete = try(var.timeouts.delete, null)
  }

  depends_on = [
    aws_iam_role_policy_attachment.service
  ]

  lifecycle {
    ignore_changes = [
      desired_count,
    ]
  }
}
