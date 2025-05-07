locals {
  metadata = {
    package = "terraform-aws-container"
    version = trimspace(file("${path.module}/../../VERSION"))
    module  = basename(path.module)
    name    = var.family_name
  }
  module_tags = {
    "module.terraform.io/name"    = "${local.metadata.package}/${local.metadata.module}"
    "module.terraform.io/version" = local.metadata.version
  }
}

locals {
  base = {
    name                   = var.container_name
    image                  = var.container_image
    essential              = var.essential
    entrypoint             = var.entrypoint
    command                = var.command
    workingDirectory       = var.working_directory
    readonlyRootFilesystem = var.readonly_root_filesystem
    mountPoints            = var.mount_points
    dnsServers             = var.dns_servers
    dnsSearchDomains       = var.dns_search_domains
    ulimits                = var.ulimits
    repositoryCredentials  = var.repository_credentials
    links                  = var.links
    volumesFrom            = var.volumes_from
    user                   = var.user
    dependsOn              = var.container_dependencies
    privileged             = var.privileged
    portMappings           = var.port_mappings
    healthCheck            = var.health_check == {} ? null : var.health_check
    firelensConfiguration  = var.firelens_configuration == {} ? null : var.firelens_configuration
    linuxParameters        = var.linux_parameters == {} ? null : var.linux_parameters
    logConfiguration       = var.log_configuration == {} ? null : var.log_configuration
    memory                 = var.container_memory
    memoryReservation      = var.container_memory_reservation
    cpu                    = var.container_cpu
    environment            = var.environment
    environmentFiles       = var.environment_files
    secrets                = var.secrets
    dockerLabels           = var.docker_labels
    startTimeout           = var.start_timeout
    stopTimeout            = var.stop_timeout
    systemControls         = var.system_controls
    extraHosts             = var.extra_hosts
    hostname               = var.hostname
    disableNetworking      = var.disable_networking
    interactive            = var.interactive
    pseudoTerminal         = var.pseudo_terminal
    dockerSecurityOptions  = var.docker_security_options
    resourceRequirements   = var.resource_requirements
  }

  container_definitions = jsonencode([
    { for k, v in local.base : k => v if v != null }
  ])
}

data "aws_region" "this" {}

# resource "aws_cloudwatch_log_group" "this" {
#   count = local.enable_cloudwatch_log_group ? 1 : 0

# name              = var.cloudwatch_log_group_config.use_name_prefix ? null : local.log_group_name
# name_prefix       = var.cloudwatch_log_group_config.use_name_prefix ? "${local.log_group_name}-" : null
# retention_in_days = var.cloudwatch_log_group_config.retention_in_days
# kms_key_id        = var.cloudwatch_log_group_config.kms_key_id

#   tags = merge(
#     {
#       "Name" = local.metadata.name
#     },
#     var.tags,
#     local.module_tags
#   )
# }

resource "aws_ecs_task_definition" "this" {
  container_definitions = local.container_definitions
  family                = var.family_name
  ipc_mode              = var.ipc_mode
  network_mode          = var.network_mode
  pid_mode              = var.pid_mode

  # Fargate requires cpu and memory to be defined at the task level
  cpu    = var.task_cpu
  memory = var.task_memory

  task_role_arn      = var.task_iam_role_arn
  execution_role_arn = var.task_exec_iam_role_arn

  dynamic "placement_constraints" {
    for_each = var.placement_constraints

    content {
      expression = placement_constraints.value.expression
      type       = placement_constraints.value.type
    }
  }

  dynamic "runtime_platform" {
    for_each = var.runtime_platform

    content {
      operating_system_family = runtime_platform.value.operating_system_family
      cpu_architecture        = runtime_platform.value.cpu_architecture
    }
  }

  dynamic "volume" {
    for_each = var.volumes

    content {
      name                = volume.value.name
      host_path           = volume.value.host_path
      configure_at_launch = volume.value.configure_at_launch

      dynamic "docker_volume_configuration" {
        for_each = volume.value.docker_volume_configuration != null ? [volume.value.docker_volume_configuration] : []

        content {
          autoprovision = docker_volume_configuration.value.autoprovision
          driver        = docker_volume_configuration.value.driver
          driver_opts   = docker_volume_configuration.value.driver_opts
          labels        = docker_volume_configuration.value.labels
          scope         = docker_volume_configuration.value.scope
        }
      }

      dynamic "efs_volume_configuration" {
        for_each = volume.value.efs_volume_configuration != null ? [volume.value.efs_volume_configuration] : []

        content {
          file_system_id          = efs_volume_configuration.value.file_system_id
          root_directory          = efs_volume_configuration.value.root_directory
          transit_encryption      = efs_volume_configuration.value.transit_encryption
          transit_encryption_port = efs_volume_configuration.value.transit_encryption_port

          dynamic "authorization_config" {
            for_each = efs_volume_configuration.value.authorization_config != null ? [efs_volume_configuration.value.authorization_config] : []

            content {
              access_point_id = authorization_config.value.access_point_id
              iam             = authorization_config.value.iam
            }
          }
        }
      }
    }
  }

  dynamic "ephemeral_storage" {
    for_each = var.ephemeral_storage != null ? [var.ephemeral_storage] : []

    content {
      size_in_gib = ephemeral_storage.value.size_in_gib
    }
  }

  tags = merge(
    {
      "Name" = local.metadata.name
    },
    local.module_tags,
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}
