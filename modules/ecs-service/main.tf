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

data "aws_region" "this" {}
data "aws_partition" "this" {}
data "aws_caller_identity" "this" {}
data "aws_ecs_cluster" "this" {
  cluster_name = var.cluster_name
}


################################################################################
# Service
################################################################################

locals {
  fargate_providers      = ["FARGATE", "FARGATE_SPOT"]
  use_capacity_providers = length(var.capacity_provider_strategies) > 0

  is_fargate = local.use_capacity_providers ? anytrue([for strategy in var.capacity_provider_strategies : contains(local.fargate_providers, strategy.name)]) : false
}

resource "aws_ecs_service" "this" {
  name                              = var.name
  cluster                           = data.aws_ecs_cluster.this.arn
  task_definition                   = var.task_definition_arn
  scheduling_strategy               = "REPLICA"
  desired_count                     = var.desired_count
  platform_version                  = local.is_fargate ? var.platform_version : null
  availability_zone_rebalancing     = var.enable_availability_zone_rebalancing ? "ENABLED" : "DISABLED"
  enable_ecs_managed_tags           = var.enable_ecs_managed_tags
  enable_execute_command            = var.enable_execute_command
  force_new_deployment              = var.force_new_deployment
  health_check_grace_period_seconds = var.health_check_grace_period_seconds
  iam_role                          = var.create_iam_role ? aws_iam_role.ecs_service[0].arn : var.iam_role_arn


  dynamic "alarms" {
    for_each = var.alarms != null ? [var.alarms] : []

    content {
      alarm_names = alarms.value.names
      enable      = alarms.value.enable
      rollback    = alarms.value.rollback
    }
  }

  dynamic "volume_configuration" {
    for_each = var.volume_configuration != null ? [var.volume_configuration] : []

    content {
      name = volume_configuration.value.name
      managed_ebs_volume {
        role_arn         = volume_configuration.value.managed_ebs_volume.role_arn
        encrypted        = volume_configuration.value.managed_ebs_volume.encrypted
        file_system_type = volume_configuration.value.managed_ebs_volume.file_system_type
        iops             = volume_configuration.value.managed_ebs_volume.iops
        kms_key_id       = volume_configuration.value.managed_ebs_volume.kms_key_id
        size_in_gb       = volume_configuration.value.managed_ebs_volume.size_in_gb
        snapshot_id      = volume_configuration.value.managed_ebs_volume.snapshot_id
        throughput       = volume_configuration.value.managed_ebs_volume.throughput
        volume_type      = volume_configuration.value.managed_ebs_volume.volume_type
        dynamic "tag_specifications" {
          for_each = volume_configuration.value.managed_ebs_volume.tag_specifications != null ? volume_configuration.value.managed_ebs_volume.tag_specifications : []

          content {
            resource_type  = tag_specifications.value.resource_type
            propagate_tags = tag_specifications.value.propagate_tags
            tags           = tag_specifications.value.tags
          }
        }
      }
    }
  }

  dynamic "capacity_provider_strategy" {
    for_each = var.capacity_provider_strategies

    content {
      base              = capacity_provider_strategy.value.base
      capacity_provider = capacity_provider_strategy.value.name
      weight            = capacity_provider_strategy.value.weight
    }
  }

  dynamic "deployment_circuit_breaker" {
    for_each = var.deployment_circuit_breaker != null ? [var.deployment_circuit_breaker] : []

    content {
      enable   = deployment_circuit_breaker.value.enable
      rollback = deployment_circuit_breaker.value.rollback
    }
  }

  deployment_controller {
    type = var.deployment_options.controller_type
  }

  deployment_maximum_percent         = var.deployment_options.maximum_healthy_percent
  deployment_minimum_healthy_percent = var.deployment_options.minimum_healthy_percent

  # NOTE: Only supported when the Task Definition uses the `awsvpc` network mode.
  dynamic "network_configuration" {
    for_each = var.network_configuration != null ? [var.network_configuration] : []

    content {
      subnets          = network_configuration.value.subnet_ids
      security_groups  = network_configuration.value.security_group_ids
      assign_public_ip = local.is_fargate ? network_configuration.value.assign_public_ip : null
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
      expression = placement_constraints.value.expression
      type       = placement_constraints.value.type
    }
  }

  dynamic "load_balancer" {
    for_each = var.load_balancers

    content {
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
      elb_name         = load_balancer.value.elb_name
      target_group_arn = load_balancer.value.target_group_arn
    }
  }

  dynamic "service_connect_configuration" {
    for_each = var.service_connect_configuration != null ? [var.service_connect_configuration] : []

    content {
      enabled   = service_connect_configuration.value.enabled
      namespace = service_connect_configuration.value.namespace

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

      dynamic "service" {
        for_each = service_connect_configuration.value.service != null ? service_connect_configuration.value.service : []

        content {
          port_name             = service.value.port_name
          discovery_name        = service.value.discovery_name
          ingress_port_override = service.value.ingress_port_override

          dynamic "client_alias" {
            for_each = service.value.client_alias != null ? service.value.client_alias : []

            content {
              port     = client_alias.value.port
              dns_name = client_alias.value.dns_name
            }
          }
        }
      }
    }
  }

  dynamic "service_registries" {
    for_each = var.service_discovery_registries != null ? [var.service_discovery_registries] : []

    content {
      registry_arn   = service_discovery_registries.value.registry_arn
      port           = service_discovery_registries.value.port
      container_port = service_discovery_registries.value.container_port
      container_name = service_discovery_registries.value.container_name
    }
  }

  triggers              = var.triggers
  wait_for_steady_state = var.wait_for_steady_state

  timeouts {
    create = var.timeouts.create
    update = var.timeouts.update
    delete = var.timeouts.delete
  }

  lifecycle {
    ignore_changes = [
      desired_count,
    ]
  }

  tags = merge(
    {
      "Name" = local.metadata.name
    },
    var.tags,
    local.module_tags
  )

}
