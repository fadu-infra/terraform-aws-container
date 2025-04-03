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
  count = var.create_service ? 1 : 0

  cluster = var.cluster_arn
  name    = var.name

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
      base              = try(capacity_provider_strategy.value.base, null)
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight            = try(capacity_provider_strategy.value.weight, null)
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
      security_groups  = network_configuration.value.security_groups
      subnets          = network_configuration.value.subnets
    }
  }

  # Ordered Placement Strategy
  dynamic "ordered_placement_strategy" {
    for_each = var.ordered_placement_strategy

    content {
      field = try(ordered_placement_strategy.value.field, null)
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
    for_each = length(var.service_connect_configuration) > 0 ? [var.service_connect_configuration] : []

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
            for_each = try([service.value.client_alias], [])

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

  # Task Definition
  task_definition = local.task_definition

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

################################################################################
# Container Definition
################################################################################

module "container_definition" {
  source = "../ecs-container-definition"

  for_each = { for k, v in var.container_definitions : k => v if local.create_task_definition && try(v.create, true) }

  operating_system_family = try(var.runtime_platform.operating_system_family, "LINUX")

  # Container Definition
  command                  = try(each.value.command, var.container_definition_defaults.command, [])
  cpu                      = try(each.value.cpu, var.container_definition_defaults.cpu, null)
  dependencies             = try(each.value.dependencies, var.container_definition_defaults.dependencies, []) # depends_on is a reserved word
  disable_networking       = try(each.value.disable_networking, var.container_definition_defaults.disable_networking, null)
  dns_search_domains       = try(each.value.dns_search_domains, var.container_definition_defaults.dns_search_domains, [])
  dns_servers              = try(each.value.dns_servers, var.container_definition_defaults.dns_servers, [])
  docker_labels            = try(each.value.docker_labels, var.container_definition_defaults.docker_labels, {})
  docker_security_options  = try(each.value.docker_security_options, var.container_definition_defaults.docker_security_options, [])
  enable_execute_command   = try(each.value.enable_execute_command, var.container_definition_defaults.enable_execute_command, var.enable_execute_command)
  entrypoint               = try(each.value.entrypoint, var.container_definition_defaults.entrypoint, [])
  environment              = try(each.value.environment, var.container_definition_defaults.environment, [])
  environment_files        = try(each.value.environment_files, var.container_definition_defaults.environment_files, [])
  essential                = try(each.value.essential, var.container_definition_defaults.essential, null)
  extra_hosts              = try(each.value.extra_hosts, var.container_definition_defaults.extra_hosts, [])
  firelens_configuration   = try(each.value.firelens_configuration, var.container_definition_defaults.firelens_configuration, {})
  health_check             = try(each.value.health_check, var.container_definition_defaults.health_check, {})
  hostname                 = try(each.value.hostname, var.container_definition_defaults.hostname, null)
  image                    = try(each.value.image, var.container_definition_defaults.image, null)
  interactive              = try(each.value.interactive, var.container_definition_defaults.interactive, false)
  links                    = try(each.value.links, var.container_definition_defaults.links, [])
  linux_parameters         = try(each.value.linux_parameters, var.container_definition_defaults.linux_parameters, {})
  log_configuration        = try(each.value.log_configuration, var.container_definition_defaults.log_configuration, {})
  memory                   = try(each.value.memory, var.container_definition_defaults.memory, null)
  memory_reservation       = try(each.value.memory_reservation, var.container_definition_defaults.memory_reservation, null)
  mount_points             = try(each.value.mount_points, var.container_definition_defaults.mount_points, [])
  name                     = try(each.value.name, each.key)
  port_mappings            = try(each.value.port_mappings, var.container_definition_defaults.port_mappings, [])
  privileged               = try(each.value.privileged, var.container_definition_defaults.privileged, false)
  pseudo_terminal          = try(each.value.pseudo_terminal, var.container_definition_defaults.pseudo_terminal, false)
  readonly_root_filesystem = try(each.value.readonly_root_filesystem, var.container_definition_defaults.readonly_root_filesystem, true)
  repository_credentials   = try(each.value.repository_credentials, var.container_definition_defaults.repository_credentials, {})
  resource_requirements    = try(each.value.resource_requirements, var.container_definition_defaults.resource_requirements, [])
  secrets                  = try(each.value.secrets, var.container_definition_defaults.secrets, [])
  start_timeout            = try(each.value.start_timeout, var.container_definition_defaults.start_timeout, 30)
  stop_timeout             = try(each.value.stop_timeout, var.container_definition_defaults.stop_timeout, 120)
  system_controls          = try(each.value.system_controls, var.container_definition_defaults.system_controls, [])
  ulimits                  = try(each.value.ulimits, var.container_definition_defaults.ulimits, [])
  user                     = try(each.value.user, var.container_definition_defaults.user, 0)
  volumes_from             = try(each.value.volumes_from, var.container_definition_defaults.volumes_from, [])
  working_directory        = try(each.value.working_directory, var.container_definition_defaults.working_directory, null)

  # CloudWatch Log Group
  service = var.name
  cloudwatch_log_group_config = {
    enable_logging    = try(each.value.enable_cloudwatch_logging, var.container_definition_defaults.enable_cloudwatch_logging, true)
    create_log_group  = try(each.value.create_cloudwatch_log_group, var.container_definition_defaults.create_cloudwatch_log_group, true)
    log_group_name    = try(each.value.cloudwatch_log_group_name, var.container_definition_defaults.cloudwatch_log_group_name, null)
    use_name_prefix   = try(each.value.cloudwatch_log_group_use_name_prefix, var.container_definition_defaults.cloudwatch_log_group_use_name_prefix, false)
    retention_in_days = try(each.value.cloudwatch_log_group_retention_in_days, var.container_definition_defaults.cloudwatch_log_group_retention_in_days, 14)
    kms_key_id        = try(each.value.cloudwatch_log_group_kms_key_id, var.container_definition_defaults.cloudwatch_log_group_kms_key_id, null)
  }

  tags = merge(
    {
      "Name" = local.metadata.name
    },
    var.tags,
    local.module_tags
  )
}

################################################################################
# Task Definition
################################################################################

locals {
  create_task_definition = var.create_task_definition

  # This allows us to query both the existing as well as Terraform's state
  # and get the max version of either source, useful for when external resources
  # update the container definition
  max_task_def_revision = local.create_task_definition ? max(aws_ecs_task_definition.this[0].revision, data.aws_ecs_task_definition.this[0].revision) : 0
  task_definition       = local.create_task_definition ? "${aws_ecs_task_definition.this[0].family}:${local.max_task_def_revision}" : var.task_definition_arn
}

# This allows us to query both the existing as well as Terraform's state and get
# and get the max version of either source, useful for when external resources
# update the container definition
data "aws_ecs_task_definition" "this" {
  count = local.create_task_definition ? 1 : 0

  task_definition = aws_ecs_task_definition.this[0].family

  depends_on = [
    # Needs to exist first on first deployment
    aws_ecs_task_definition.this
  ]
}

resource "aws_ecs_task_definition" "this" {
  count = local.create_task_definition ? 1 : 0

  # Convert map of maps to array of maps before JSON encoding
  container_definitions = jsonencode([for k, v in module.container_definition : v.container_definition])
  cpu                   = var.cpu

  dynamic "ephemeral_storage" {
    for_each = length(var.ephemeral_storage) > 0 ? [var.ephemeral_storage] : []

    content {
      size_in_gib = ephemeral_storage.value.size_in_gib
    }
  }

  execution_role_arn = try(aws_iam_role.task_exec[0].arn, var.task_exec_iam_role_arn)
  family             = coalesce(var.family, var.name)

  /*
  dynamic "inference_accelerator" {
    for_each = var.inference_accelerator

    content {
      device_name = inference_accelerator.value.device_name
      device_type = inference_accelerator.value.device_type
    }
  }
  */

  ipc_mode     = var.ipc_mode
  memory       = var.memory
  network_mode = var.network_mode
  pid_mode     = var.pid_mode

  dynamic "placement_constraints" {
    for_each = var.task_definition_placement_constraints

    content {
      expression = try(placement_constraints.value.expression, null)
      type       = placement_constraints.value.type
    }
  }

  /*
  dynamic "proxy_configuration" {
    for_each = length(var.proxy_configuration) > 0 ? [var.proxy_configuration] : []

    content {
      container_name = proxy_configuration.value.container_name
      properties     = try(proxy_configuration.value.properties, null)
      type           = try(proxy_configuration.value.type, null)
    }
  }
  */

  requires_compatibilities = var.requires_compatibilities

  dynamic "runtime_platform" {
    for_each = length(var.runtime_platform) > 0 ? [var.runtime_platform] : []

    content {
      cpu_architecture        = try(runtime_platform.value.cpu_architecture, null)
      operating_system_family = try(runtime_platform.value.operating_system_family, null)
    }
  }

  skip_destroy  = var.skip_destroy
  task_role_arn = try(aws_iam_role.tasks[0].arn, var.tasks_iam_role_arn)

  dynamic "volume" {
    for_each = var.volume

    content {
      dynamic "docker_volume_configuration" {
        for_each = try([volume.value.docker_volume_configuration], [])

        content {
          autoprovision = try(docker_volume_configuration.value.autoprovision, null)
          driver        = try(docker_volume_configuration.value.driver, null)
          driver_opts   = try(docker_volume_configuration.value.driver_opts, null)
          labels        = try(docker_volume_configuration.value.labels, null)
          scope         = try(docker_volume_configuration.value.scope, null)
        }
      }

      dynamic "efs_volume_configuration" {
        for_each = try([volume.value.efs_volume_configuration], [])

        content {
          dynamic "authorization_config" {
            for_each = try([efs_volume_configuration.value.authorization_config], [])

            content {
              access_point_id = try(authorization_config.value.access_point_id, null)
              iam             = try(authorization_config.value.iam, null)
            }
          }

          file_system_id          = efs_volume_configuration.value.file_system_id
          root_directory          = try(efs_volume_configuration.value.root_directory, null)
          transit_encryption      = try(efs_volume_configuration.value.transit_encryption, null)
          transit_encryption_port = try(efs_volume_configuration.value.transit_encryption_port, null)
        }
      }

      dynamic "fsx_windows_file_server_volume_configuration" {
        for_each = try([volume.value.fsx_windows_file_server_volume_configuration], [])

        content {
          dynamic "authorization_config" {
            for_each = try([fsx_windows_file_server_volume_configuration.value.authorization_config], [])

            content {
              credentials_parameter = authorization_config.value.credentials_parameter
              domain                = authorization_config.value.domain
            }
          }

          file_system_id = fsx_windows_file_server_volume_configuration.value.file_system_id
          root_directory = fsx_windows_file_server_volume_configuration.value.root_directory
        }
      }

      host_path = try(volume.value.host_path, null)
      name      = try(volume.value.name, volume.key)
    }
  }

  tags = merge(
    {
      "Name" = local.metadata.name
    },
    var.task_tags,
    local.module_tags,
    var.tags
  )

  depends_on = [
    aws_iam_role_policy_attachment.tasks,
    aws_iam_role_policy_attachment.task_exec,
    aws_iam_role_policy_attachment.task_exec_additional,
  ]

  lifecycle {
    create_before_destroy = true
  }
}
