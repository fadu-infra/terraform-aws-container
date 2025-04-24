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

  enable_cloudwatch_log_group = var.cloudwatch_log_group_config.create_log_group && var.cloudwatch_log_group_config.enable_logging

  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition
  region     = data.aws_region.current.name

  is_not_windows = contains(["LINUX"], var.operating_system_family)

  log_group_name = try(
    coalesce(
      var.cloudwatch_log_group_config.log_group_name,
      "/aws/ecs/${var.service}/${var.name}"
    ),
    "/aws/ecs/${var.service}/default"
  )

  default_log_config = var.cloudwatch_log_group_config.enable_logging ? {
    logDriver = "awslogs"
    options = {
      awslogs-region        = data.aws_region.current.name
      awslogs-group         = local.enable_cloudwatch_log_group ? aws_cloudwatch_log_group.this[0].name : ""
      awslogs-stream-prefix = "ecs"
    }
    } : {
    logDriver = null
    options   = {}
  }

  log_configuration = merge(
    local.default_log_config,
    var.log_configuration
  )

  linux_parameters = var.enable_execute_command ? merge({ "initProcessEnabled" : true }, var.linux_parameters) : merge({ "initProcessEnabled" : false }, var.linux_parameters)

  health_check = length(var.health_check) > 0 ? merge({
    interval = 30,
    retries  = 3,
    timeout  = 5
  }, var.health_check) : null

  definition = {
    command                = var.command
    cpu                    = var.container_cpu
    dependsOn              = length(var.dependencies) > 0 ? var.dependencies : null # depends_on is a reserved word
    disableNetworking      = local.is_not_windows ? var.disable_networking : null
    dnsSearchDomains       = local.is_not_windows && length(var.dns_search_domains) > 0 ? var.dns_search_domains : null
    dnsServers             = local.is_not_windows && length(var.dns_servers) > 0 ? var.dns_servers : null
    dockerLabels           = length(var.docker_labels) > 0 ? var.docker_labels : null
    dockerSecurityOptions  = length(var.docker_security_options) > 0 ? var.docker_security_options : null
    entrypoint             = length(var.entrypoint) > 0 ? var.entrypoint : null
    environment            = var.environment
    environmentFiles       = length(var.environment_files) > 0 ? var.environment_files : null
    essential              = var.essential
    extraHosts             = local.is_not_windows && length(var.extra_hosts) > 0 ? var.extra_hosts : null
    firelensConfiguration  = length(var.firelens_configuration) > 0 ? var.firelens_configuration : null
    healthCheck            = local.health_check
    hostname               = var.hostname
    image                  = var.image
    interactive            = var.interactive
    links                  = local.is_not_windows && length(var.links) > 0 ? var.links : null
    linuxParameters        = local.is_not_windows && length(local.linux_parameters) > 0 ? local.linux_parameters : null
    logConfiguration       = length(local.log_configuration) > 0 ? local.log_configuration : null
    memory                 = var.container_memory
    memoryReservation      = var.memory_reservation
    mountPoints            = var.mount_points
    name                   = var.name
    portMappings           = var.port_mappings
    privileged             = local.is_not_windows ? var.privileged : null
    pseudoTerminal         = var.pseudo_terminal
    readonlyRootFilesystem = local.is_not_windows ? var.readonly_root_filesystem : null
    repositoryCredentials  = length(var.repository_credentials) > 0 ? var.repository_credentials : null
    resourceRequirements   = length(var.resource_requirements) > 0 ? var.resource_requirements : null
    secrets                = length(var.secrets) > 0 ? var.secrets : null
    startTimeout           = var.start_timeout
    stopTimeout            = var.stop_timeout
    systemControls         = length(var.system_controls) > 0 ? var.system_controls : []
    ulimits                = local.is_not_windows && length(var.ulimits) > 0 ? var.ulimits : null
    user                   = local.is_not_windows ? var.user : null
    volumesFrom            = var.volumes_from
    workingDirectory       = var.working_directory
  }

  container_definition = { for k, v in local.definition : k => v if v != null }
}

resource "aws_cloudwatch_log_group" "this" {
  count = local.enable_cloudwatch_log_group ? 1 : 0

  name              = var.cloudwatch_log_group_config.use_name_prefix ? null : local.log_group_name
  name_prefix       = var.cloudwatch_log_group_config.use_name_prefix ? "${local.log_group_name}-" : null
  retention_in_days = var.cloudwatch_log_group_config.retention_in_days
  kms_key_id        = var.cloudwatch_log_group_config.kms_key_id

  tags = merge(
    {
      "Name" = local.metadata.name
    },
    var.tags,
    local.module_tags
  )
}

resource "aws_ecs_task_definition" "this" {
  container_definitions = jsonencode([local.container_definition])
  cpu                   = var.task_cpu

  dynamic "ephemeral_storage" {
    for_each = length(var.ephemeral_storage) > 0 ? [var.ephemeral_storage] : []

    content {
      size_in_gib = ephemeral_storage.value.size_in_gib
    }
  }

  execution_role_arn = var.create_task_exec_iam_role ? aws_iam_role.task_exec[0].arn : var.task_exec_iam_role_arn
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
  memory       = var.task_memory
  network_mode = var.network_mode
  pid_mode     = var.pid_mode

  dynamic "placement_constraints" {
    for_each = var.task_definition_placement_constraints

    content {
      expression = placement_constraints.value.expression
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
      cpu_architecture        = runtime_platform.value.cpu_architecture
      operating_system_family = runtime_platform.value.operating_system_family
    }
  }

  skip_destroy  = var.skip_destroy
  task_role_arn = var.create_tasks_iam_role ? aws_iam_role.tasks[0].arn : var.tasks_iam_role_arn

  dynamic "volume" {
    for_each = var.volume

    content {
      dynamic "docker_volume_configuration" {
        for_each = [volume.value.docker_volume_configuration]

        content {
          autoprovision = docker_volume_configuration.value.autoprovision
          driver        = docker_volume_configuration.value.driver
          driver_opts   = docker_volume_configuration.value.driver_opts
          labels        = docker_volume_configuration.value.labels
          scope         = docker_volume_configuration.value.scope
        }
      }

      dynamic "efs_volume_configuration" {
        for_each = [volume.value.efs_volume_configuration]

        content {
          dynamic "authorization_config" {
            for_each = [efs_volume_configuration.value.authorization_config]

            content {
              access_point_id = authorization_config.value.access_point_id
              iam             = authorization_config.value.iam
            }
          }

          file_system_id          = efs_volume_configuration.value.file_system_id
          root_directory          = efs_volume_configuration.value.root_directory
          transit_encryption      = efs_volume_configuration.value.transit_encryption
          transit_encryption_port = efs_volume_configuration.value.transit_encryption_port
        }
      }

      dynamic "fsx_windows_file_server_volume_configuration" {
        for_each = [volume.value.fsx_windows_file_server_volume_configuration]

        content {
          dynamic "authorization_config" {
            for_each = [fsx_windows_file_server_volume_configuration.value.authorization_config]

            content {
              credentials_parameter = authorization_config.value.credentials_parameter
              domain                = authorization_config.value.domain
            }
          }

          file_system_id = fsx_windows_file_server_volume_configuration.value.file_system_id
          root_directory = fsx_windows_file_server_volume_configuration.value.root_directory
        }
      }

      host_path = volume.value.host_path
      name      = coalesce(volume.value.name, volume.key)
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

  lifecycle {
    create_before_destroy = true
  }
}
