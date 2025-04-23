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
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/deployment-type-external.html
  is_daemon  = var.scheduling_strategy == "DAEMON"
  is_fargate = var.launch_type == "FARGATE"
}

resource "aws_ecs_service" "this" {
  cluster         = var.cluster_arn
  name            = var.name
  task_definition = var.task_definition_arn

  # CloudWatch Alarms
  dynamic "alarms" {
    for_each = var.alarms

    content {
      alarm_names = alarms.value.alarm_names
      enable      = alarms.value.enable
      rollback    = alarms.value.rollback
    }
  }

  # Capacity Provider Strategy
  dynamic "capacity_provider_strategy" {
    for_each = var.capacity_provider_strategy

    content {
      base              = capacity_provider_strategy.value.base
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight            = capacity_provider_strategy.value.weight
    }
  }

  # Deployment Circuit Breaker
  deployment_circuit_breaker {
    enable   = var.deployment_setting.circuit_breaker.enable
    rollback = var.deployment_setting.circuit_breaker.rollback
  }

  # Deployment Settings
  deployment_maximum_percent         = local.is_daemon ? null : var.deployment_setting.maximum_percent
  deployment_minimum_healthy_percent = local.is_daemon ? null : var.deployment_setting.minimum_healthy_percent
  desired_count                      = local.is_daemon ? null : var.desired_count
  enable_ecs_managed_tags            = var.enable_ecs_managed_tags
  enable_execute_command             = var.enable_execute_command
  force_new_deployment               = var.force_new_deployment
  health_check_grace_period_seconds  = var.health_check_grace_period_seconds
  iam_role                           = local.iam_role_arn
  launch_type                        = length(var.capacity_provider_strategy) > 0 ? null : var.launch_type

  # Network Configuration
  dynamic "network_configuration" {
    for_each = var.network_mode == "awsvpc" ? [var.network_configuration] : []

    content {
      assign_public_ip = network_configuration.value.assign_public_ip
      security_groups  = network_configuration.value.security_group_ids
      subnets          = network_configuration.value.subnet_ids
    }
  }

  # Ordered Placement Strategy
  dynamic "ordered_placement_strategy" {
    for_each = var.ordered_placement_strategy

    content {
      field = ordered_placement_strategy.value.field
      type  = ordered_placement_strategy.value.type
    }
  }

  # Placement Constraints
  dynamic "placement_constraints" {
    for_each = var.placement_constraints

    content {
      expression = try(placement_constraints.value.expression, null)
      type       = placement_constraints.value.type
    }
  }

  # Platform Version
  platform_version = local.is_fargate ? var.platform_version : null

  # Scheduling Strategy
  scheduling_strategy = local.is_fargate ? "REPLICA" : var.scheduling_strategy

  # Load Balancer
  dynamic "load_balancer" {
    for_each = var.load_balancers

    content {
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
      elb_name         = try(load_balancer.value.elb_name, null)
      target_group_arn = try(load_balancer.value.target_group_arn, null)
    }
  }

  # Service Connect Configuration
  dynamic "service_connect_configuration" {
    for_each = var.service_connect_configuration == {} ? [] : [var.service_connect_configuration]

    content {
      enabled = try(service_connect_configuration.value.enabled, true)

      dynamic "log_configuration" {
        for_each = try([service_connect_configuration.value.log_configuration], [])

        content {
          log_driver = try(log_configuration.value.log_driver, null)
          options    = try(log_configuration.value.options, null)

          dynamic "secret_option" {
            for_each = try(log_configuration.value.secret_option, [])

            content {
              name       = secret_option.value.name
              value_from = secret_option.value.value_from
            }
          }
        }
      }

      namespace = lookup(service_connect_configuration.value, "namespace", null)

      dynamic "service" {
        for_each = try([service_connect_configuration.value.service], [])

        content {

          dynamic "client_alias" {
            for_each = service.value.client_alias != null ? [service.value.client_alias] : []

            content {
              dns_name = try(client_alias.value.dns_name, null)
              port     = client_alias.value.port
            }
          }

          discovery_name        = try(service.value.discovery_name, null)
          ingress_port_override = try(service.value.ingress_port_override, null)
          port_name             = service.value.port_name
        }
      }
    }
  }

  # Service Registries
  dynamic "service_registries" {
    for_each = length(var.service_discovery_registries) > 0 ? [{ for k, v in var.service_discovery_registries : k => v if !local.is_daemon }] : []

    content {
      container_name = try(service_registries.value.container_name, null)
      container_port = try(service_registries.value.container_port, null)
      port           = try(service_registries.value.port, null)
      registry_arn   = service_registries.value.registry_arn
    }
  }

  # Triggers
  triggers = var.triggers

  # Wait for Steady State
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
      desired_count, # Always ignored
    ]
  }
}
