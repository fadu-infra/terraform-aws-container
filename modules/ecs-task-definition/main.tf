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

data "aws_region" "this" {}

locals {
  command                 = jsonencode(var.command)
  container_dependencies  = jsonencode(var.container_dependencies)
  dns_search_domains      = jsonencode(var.dns_search_domains)
  dns_servers             = jsonencode(var.dns_servers)
  docker_labels           = jsonencode(var.docker_labels)
  docker_security_options = jsonencode(var.docker_security_options)
  entrypoint              = jsonencode(var.entrypoint)
  environment             = jsonencode(var.environment)
  environment_files       = jsonencode(var.environment_files)
  extra_hosts             = jsonencode(var.extra_hosts)
  firelens_configuration  = jsonencode(var.firelens_configuration)
  health_check            = jsonencode(var.health_check)
  links                   = jsonencode(var.links)
  linux_parameters        = jsonencode(var.linux_parameters)
  log_configuration       = jsonencode(var.log_configuration)
  mount_points            = jsonencode(var.mount_points)
  port_mappings           = jsonencode(var.port_mappings)
  repository_credentials  = jsonencode(var.repository_credentials)
  resource_requirements   = jsonencode(var.resource_requirements)
  secrets                 = jsonencode(var.secrets)
  system_controls         = jsonencode(var.system_controls)
  ulimits                 = jsonencode(var.ulimits)
  volumes_from            = jsonencode(var.volumes_from)


  container_definition_template = templatefile(
    "${path.module}/container-definition.json.tpl",
    {
      # Simple types (passed directly or jsonencoded if nullable string)
      name                   = var.container_name == null ? "null" : jsonencode(var.container_name)
      image                  = var.container_image == null ? "null" : jsonencode(var.container_image)
      cpu                    = var.container_cpu == null ? "null" : var.container_cpu
      memory                 = var.container_memory == null ? "null" : var.container_memory
      memoryReservation      = var.container_memory_reservation == null ? "null" : var.container_memory_reservation
      essential              = var.essential
      disableNetworking      = var.disable_networking
      interactive            = var.interactive
      pseudoTerminal         = var.pseudo_terminal
      privileged             = var.privileged
      readonlyRootFilesystem = var.readonly_root_filesystem
      hostname               = var.hostname == null ? "null" : jsonencode(var.hostname)
      user                   = var.user == null ? "null" : jsonencode(var.user)
      workingDirectory       = var.working_directory == null ? "null" : jsonencode(var.working_directory)
      startTimeout           = var.start_timeout
      stopTimeout            = var.stop_timeout

      # Lists (json encoded, then null if empty string "[]")
      command               = local.command == "[]" ? "null" : local.command
      containerDependencies = local.container_dependencies == "[]" ? "null" : local.container_dependencies
      dnsSearchDomains      = local.dns_search_domains == "[]" ? "null" : local.dns_search_domains
      dnsServers            = local.dns_servers == "[]" ? "null" : local.dns_servers
      dockerSecurityOptions = local.docker_security_options == "[]" ? "null" : local.docker_security_options
      entryPoint            = local.entrypoint == "[]" ? "null" : local.entrypoint
      environment           = local.environment == "[]" ? "null" : local.environment
      environmentFiles      = local.environment_files == "[]" ? "null" : local.environment_files
      extraHosts            = local.extra_hosts == "[]" ? "null" : local.extra_hosts
      links                 = local.links == "[]" ? "null" : local.links
      mountPoints           = local.mount_points == "[]" ? "null" : local.mount_points
      portMappings          = local.port_mappings == "[]" ? "null" : local.port_mappings
      resourceRequirements  = local.resource_requirements == "[]" ? "null" : local.resource_requirements
      secrets               = local.secrets == "[]" ? "null" : local.secrets
      systemControls        = local.system_controls == "[]" ? "null" : local.system_controls
      ulimits               = local.ulimits == "[]" ? "null" : local.ulimits
      volumesFrom           = local.volumes_from == "[]" ? "null" : local.volumes_from

      # Maps/Objects (json encoded, then null if empty string "{}")
      dockerLabels          = local.docker_labels == "{}" ? "null" : local.docker_labels
      firelensConfiguration = local.firelens_configuration == "{}" ? "null" : local.firelens_configuration
      healthCheck           = local.health_check == "{}" ? "null" : local.health_check
      linuxParameters       = local.linux_parameters == "{}" ? "null" : local.linux_parameters
      logConfiguration      = local.log_configuration == "{}" ? "null" : local.log_configuration
      repositoryCredentials = local.repository_credentials == "{}" ? "null" : local.repository_credentials
    }
  )

  container_definitions = replace(local.container_definition_template, "/\"(null)\"/", "$1")
}

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
