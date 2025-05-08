################################################################################
# Infrastructure
################################################################################

variable "family_name" {
  description = "(Required) The family of the task definition"
  type        = string
  nullable    = false
}

variable "network_mode" {
  description = "(Optional) Docker networking mode to use for the containers in the task. Valid values are `none`, `bridge`, `awsvpc`, and `host`"
  type        = string
  default     = "awsvpc"
  nullable    = false

  validation {
    condition     = contains(["none", "bridge", "awsvpc", "host"], var.network_mode)
    error_message = "The 'network_mode' must be one of 'none', 'bridge', 'awsvpc', or 'host'."
  }
}

variable "runtime_platform" {
  description = <<-EOT
  (Optional) Configuration block for `runtime_platform` that containers in your task may use.
    (Optional) `operating_system_family`: The operating system associated with the task definition.
    (Optional) `cpu_architecture`: The CPU architecture associated with the task definition.
  EOT
  type = object({
    operating_system_family = optional(string)
    cpu_architecture        = optional(string)
  })
  default  = {}
  nullable = false
}

variable "skip_destroy" {
  description = "(Optional) If true, the task is not deleted when the service is deleted. Useful for retaining task definition revisions."
  type        = bool
  default     = false
  nullable    = false
}

variable "task_cpu" {
  description = "(Optional) The number of CPU units to reserve for the task. Required for Fargate."
  type        = number
  default     = null
  nullable    = true
}

variable "task_memory" {
  description = "(Optional) The amount (in MiB) of memory to present to the task. Required for Fargate."
  type        = number
  default     = null
  nullable    = true
}

variable "placement_constraints" {
  description = <<-EOT
  (Optional) Configuration block for rules considered during task placement.
    (Optional) `expression`: The expression to apply to the constraint.
    (Optional) `type`: The type of constraint.
  EOT
  type = list(object({
    expression = optional(string, null)
    type       = string
  }))
  default  = []
  nullable = false
}

variable "requires_compatibilities" {
  description = "(Optional) Set of launch types required by the task. The valid values are `EC2` and `FARGATE`"
  type        = list(string)
  default     = ["FARGATE"]
  nullable    = false
  validation {
    condition     = alltrue([for compatibility in var.requires_compatibilities : contains(["EC2", "FARGATE"], compatibility)])
    error_message = "Each value in 'requires_compatibilities' must be either 'EC2' or 'FARGATE'."
  }
}

################################################################################
# Container Definitions
################################################################################

variable "container_name" {
  description = "(Optional) The name of a container. If not provided, the task family name may be used by default in some contexts."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition     = var.container_name == null || length(regexall("^[a-zA-Z0-9-_]{1,255}$", var.container_name)) > 0
    error_message = "The container name must be between 1 and 255 characters and can only contain letters, numbers, hyphens, and underscores."
  }
}

variable "container_image" {
  description = "(Required) The image used to start a container."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition     = var.container_image == null || length(regexall("^[a-zA-Z0-9-_:/.#@]{1,255}$", var.container_image)) > 0
    error_message = "The image must be between 1 and 255 characters and can only contain letters, numbers, hyphens, underscores, colons, periods, forward slashes, hash signs, and at signs."
  }
}

variable "essential" {
  description = "(Optional) If the `essential` parameter of a container is marked as `true` (default), and that container fails or stops for any reason, all other containers that are part of the task are stopped."
  type        = bool
  default     = true
  nullable    = false
}

variable "command" {
  description = "(Optional) The command that's passed to the container, overriding the CMD in the Dockerfile."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "container_cpu" {
  description = "(Optional) The number of cpu units to reserve for the container. This is a share of the task_cpu."
  type        = number
  default     = null
  nullable    = true
}

variable "container_memory" {
  description = "(Optional) The amount (in MiB) of memory to present to the container (hard limit)."
  type        = number
  default     = null
  nullable    = true
}

variable "container_memory_reservation" {
  description = "(Optional) The soft limit (in MiB) of memory to reserve for the container."
  type        = number
  default     = null
  nullable    = true
}

variable "container_dependencies" {
  description = <<EOT
  (Optional) The dependencies defined for container startup and shutdown.
    (Required) `condition`: The dependency condition. Valid values are `START`, `COMPLETE`, `SUCCESS`, `HEALTHY`.
    (Required) `containerName`: The name of the container that this dependency is associated with.
  EOT
  type = list(object({
    condition     = string
    containerName = string
  }))
  default  = []
  nullable = false

  validation {
    condition = alltrue([
      for dep in var.container_dependencies :
      contains(["START", "COMPLETE", "SUCCESS", "HEALTHY"], dep.condition)
    ])
    error_message = "The condition must be one of: START, COMPLETE, SUCCESS, HEALTHY."
  }
}

variable "disable_networking" {
  description = "(Optional) When this parameter is true, networking is disabled within the container"
  type        = bool
  default     = false
  nullable    = false
}

variable "dns_search_domains" {
  description = "(Optional) Container DNS search domains. A list of DNS search domains that are presented to the container"
  type        = list(string)
  default     = []
  nullable    = false
}

variable "dns_servers" {
  description = "(Optional) Container DNS servers. This is a list of strings specifying the IP addresses of the DNS servers"
  type        = list(string)
  default     = []
  nullable    = false
}

variable "docker_labels" {
  description = "(Optional) A key/value map of labels to add to the container."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "docker_security_options" {
  description = "(Optional) A list of strings to provide custom labels for SELinux and AppArmor. Not for Fargate."
  type        = list(string)
  default     = []
  nullable    = false

  validation {
    condition = length(var.docker_security_options) == 0 || alltrue([
      for option in var.docker_security_options :
      length(regexall("^(no-new-privileges|apparmor:[^:]+|label:[^:]+|credentialspec:[^:]+)$", option)) > 0
    ])
    error_message = "Each docker_security_option must be one of: 'no-new-privileges', 'apparmor:PROFILE', 'label:value', or 'credentialspec:CredentialSpecFilePath'."
  }
}

variable "enable_execute_command" {
  description = "(Optional) Specifies whether to enable Amazon ECS Exec for the tasks."
  type        = bool
  default     = false
  nullable    = false
}

variable "entrypoint" {
  description = "(Optional) The entry point that is passed to the container, overriding the ENTRYPOINT in the Dockerfile."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "environment" {
  description = <<-EOT
  (Optional) The environment variables to pass to the container
    (Required) `name`: The name of the environment variable
    (Required) `value`: The value of the environment variable
  EOT
  type = list(object({
    name  = string
    value = string
  }))
  default  = []
  nullable = false
}

variable "environment_files" {
  description = <<-EOT
  (Optional) A list of files containing the environment variables to pass to a container. You can specify up to ten environment files.
    (Required) `value`: The Amazon Resource Name (ARN) of the Amazon S3 object containing the environment variable file.
    (Required) `type`: The file type to use. The only supported value is `s3`.
  EOT
  type = list(object({
    value = string
    type  = string
  }))
  default  = []
  nullable = false
}

variable "extra_hosts" {
  description = <<-EOT
  (Optional) A list of hostnames and IP address mappings to append to the `/etc/hosts` file on the container
    (Required) `hostname`: The hostname to add
    (Required) `ipAddress`: The IP address to add
  EOT
  type = list(object({
    hostname  = string
    ipAddress = string
  }))
  default  = []
  nullable = false
}

variable "firelens_configuration" {
  description = <<-EOT
  (Optional) The FireLens configuration for the container, used to specify and configure a log router for container logs. For more details, refer to the Amazon ECS Developer Guide on Custom Log Routing.
    (Required) `type`: The log router to use. Valid values are `fluentd` or `fluentbit`.
    (Optional) `options`: A map of key-value pairs to configure the log router. These options allow customization of the log routing behavior.
  EOT
  type = object({
    type    = string
    options = optional(map(string))
  })
  default  = null
  nullable = true
}

variable "health_check" {
  description = <<-EOT
  (Optional) The container health check command and associated configuration parameters for the container.
    (Optional) `command`: The command that the container runs to determine if it is healthy.
    (Optional) `interval`: The time period in seconds between each health check execution.
    (Optional) `timeout`: The time period in seconds to wait for a health check to succeed.
    (Optional) `retries`: The number of times to retry a failed health check before the container is considered unhealthy.
    (Optional) `startPeriod`: The time period in seconds to wait for a health check to get a response from the command.
  EOT
  type = object({
    command     = optional(list(string))
    interval    = optional(number, 30)
    timeout     = optional(number, 5)
    retries     = optional(number, 3)
    startPeriod = optional(number, 0)
  })
  default  = {}
  nullable = false
}

variable "hostname" {
  description = "(Optional) The hostname to use for your container. Up to 255 letters (uppercase and lowercase), numbers, hyphens, underscores, colons, periods, forward slashes, and number signs are allowed. Cannot be set when network_mode is 'awsvpc'"
  type        = string
  default     = null
  nullable    = true

  validation {
    condition     = var.hostname == null || try(regex("^[a-zA-Z0-9-_:/.#]{1,255}$", var.hostname), false)
    error_message = "The hostname must be between 1 and 255 characters and can only contain letters, numbers, hyphens, underscores, colons, periods, forward slashes, and number signs."
  }
}

variable "interactive" {
  description = "(Optional) When true, you can deploy containerized applications that require stdin or a TTY to be allocated."
  type        = bool
  default     = false
  nullable    = false
}

variable "links" {
  description = "(Optional) The links parameter allows containers to communicate without port mappings (bridge network mode only)."
  type        = list(string)
  default     = []
  nullable    = false

  validation {
    condition = length(var.links) == 0 || alltrue([
      for link in var.links :
      length(regexall("^[a-zA-Z0-9-_]{1,255}:[a-zA-Z0-9-_]{1,255}$", link)) > 0
    ])
    error_message = "Each link must be in the format 'containerName:alias'."
  }
}

variable "linux_parameters" {
  description = <<-EOT
  (Optional) Linux-specific modifications that are applied to the container, such as Linux kernel capabilities.
    (Optional) `capabilities`: The Linux capabilities for the container that are added to or dropped from the default configuration provided by Docker.
    (Optional) `devices`: Any host devices to expose to the container.
    (Optional) `initProcessEnabled`: Run an init process inside the container that forwards signals and reaps processes.
    (Optional) `maxSwap`: The total amount of swap memory (in MiB) a container can use.
    (Optional) `sharedMemorySize`: The size (in MiB) of the /dev/shm volume.
    (Optional) `swappiness`: Tune a container's memory swappiness behavior.
    (Optional) `tmpfs`: The container path, mount options, and size (in MiB) of the tmpfs mount.
  Note: Some parameters are not supported for tasks using the Fargate launch type.
  EOT
  type = object({
    capabilities = optional(object({
      add  = optional(list(string))
      drop = optional(list(string))
    }))
    devices = optional(list(object({
      hostPath      = string
      containerPath = optional(string)
      permissions   = optional(list(string))
    })))
    initProcessEnabled = optional(bool, false)
    maxSwap            = optional(number)
    sharedMemorySize   = optional(number)
    swappiness         = optional(number)
    tmpfs = optional(list(object({
      containerPath = string
      size          = number
      mountOptions  = optional(list(string))
    })))
  })
  default  = {}
  nullable = false
}

variable "log_configuration" {
  description = <<-EOT
  (Optional) The log configuration for the container.
    (Optional) `logDriver`: The log driver to use for the container.
    (Optional) `options`: The configuration options to send to the log driver.
    (Optional) `secretOptions`: The secrets to pass to the log configuration.
  EOT
  type = object({
    logDriver = optional(string, "awslogs")
    options   = optional(map(string))
    secretOptions = optional(list(object({
      name      = string
      valueFrom = string
    })))
  })
  default  = {}
  nullable = false
}

variable "mount_points" {
  description = <<-EOT
  (Optional) The mount points for data volumes in your container
    (Optional) `containerPath`: The path on the container to mount the volume at.
    (Optional) `readOnly`: If this value is `true`, the container has read-only access to the volume.
    (Optional) `sourceVolume`: The name of the volume to mount.
  EOT
  type = list(object({
    containerPath = string
    readOnly      = optional(bool, false)
    sourceVolume  = string
  }))
  default  = []
  nullable = false
}

variable "port_mappings" {
  description = <<-EOT
  (Optional) The list of port mappings for the container. Port mappings allow containers to access ports on the host container instance to send or receive traffic. For task definitions that use the awsvpc network mode, only specify the containerPort. The hostPort can be left blank or it must be the same value as the containerPort
    (Optional) `containerPort`: The port number on the container that is used with the network protocol.
    (Optional) `hostPort`: The port number on the host that is used with the network protocol.
    (Optional) `protocol`: The protocol used for the port mapping.
    (Optional) `appProtocol`: The application protocol to use for the port mapping.
    (Optional) `name`: The name to give the port mapping.
  EOT
  type = list(object({
    containerPort = number
    hostPort      = optional(number)
    protocol      = optional(string, "tcp")
    appProtocol   = optional(string)
    name          = optional(string)
  }))
  default  = []
  nullable = false
}

variable "privileged" {
  description = "(Optional) When true, the container is given elevated privileges on the host (similar to root). Not for Fargate."
  type        = bool
  default     = false
  nullable    = false
}

variable "pseudo_terminal" {
  description = "(Optional) When true, a TTY is allocated."
  type        = bool
  default     = false
  nullable    = false
}

variable "readonly_root_filesystem" {
  description = "(Optional) When true, the container is given read-only access to its root file system."
  type        = bool
  default     = false
  nullable    = false
}

variable "repository_credentials" {
  description = "(Optional) Container repository credentials for private ECR image. Use \"credentialsParameter\" for Secrets Manager ARN."
  type = object({
    credentialsParameter = optional(string)
  })
  default  = null
  nullable = true
}

variable "resource_requirements" {
  description = <<-EOT
  (Optional) The type and amount of a resource to assign to a container. The only supported resource is a GPU
    (Required) `type`: The type of resource to assign to the container. Must be `GPU`.
    (Required) `value`: The value for the specified resource type.
  EOT
  type = list(object({
    type  = string # Only "GPU" is currently supported
    value = string
  }))
  default  = []
  nullable = false
}

variable "secrets" {
  description = <<-EOT
  (Optional) The secrets to pass to the container.
    (Required) `name`: The name of the secret to pass to the container
    (Required) `valueFrom`: The value from the secret to pass to the container (ARN of the Secret or SSM parameter)
  EOT
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default  = []
  nullable = false
}

variable "start_timeout" {
  description = "(Optional) Time duration (seconds) to wait before giving up on resolving dependencies for a container."
  type        = number
  default     = null
  nullable    = true

  validation {
    condition     = var.start_timeout == null || (var.start_timeout >= 0)
    error_message = "The start_timeout must be a non-negative integer."
  }
}

variable "stop_timeout" {
  description = "(Optional) Time duration (seconds) to wait before the container is forcefully killed if it doesn't exit normally."
  type        = number
  default     = 30
  nullable    = false

  validation {
    condition     = var.stop_timeout == null || (var.stop_timeout >= 0 && var.stop_timeout <= 120)
    error_message = "The stop_timeout must be between 0 and 120 seconds."
  }
}

variable "system_controls" {
  description = <<-EOT
  (Optional) A list of namespaced kernel parameters to set in the container
    (Required) `namespace`: The namespace to set the kernel parameter in
    (Required) `value`: The value of the kernel parameter
  EOT
  type = list(object({
    namespace = string
    value     = string
  }))
  default  = []
  nullable = false
}

variable "ulimits" {
  description = <<-EOT
  (Optional) A list of ulimits to set in the container. If a ulimit value is specified in a task definition, it overrides the default values set by Docker
    (Required) `hardLimit`: The hard limit for the ulimit
    (Required) `name`: The name of the ulimit
    (Required) `softLimit`: The soft limit for the ulimit
  EOT
  type = list(object({
    hardLimit = number
    name      = string
    softLimit = number
  }))
  default  = []
  nullable = false

  validation {
    condition = alltrue([
      for ulimit in var.ulimits : contains(
        ["core", "cpu", "data", "fsize", "locks", "memlock", "msgqueue", "nice", "nofile", "nproc", "rss", "rtprio", "rttime", "sigpending", "stack"],
        ulimit.name
      )
    ])
    error_message = "Each ulimit name must be one of the valid AWS ECS ulimit names."
  }

  validation {
    condition = alltrue([
      for ulimit in var.ulimits : ulimit.hardLimit >= ulimit.softLimit
    ])
    error_message = "The hardLimit must be greater than or equal to the softLimit for each ulimit."
  }
}

variable "user" {
  description = "(Optional) The user to run as inside the container."
  type        = string
  default     = null
  nullable    = true
}

variable "volumes_from" {
  description = "(Optional) Data volumes to mount from another container"
  type = list(object({
    readOnly        = optional(bool, false)
    sourceContainer = optional(string)
  }))
  default  = []
  nullable = false
}

variable "working_directory" {
  description = "(Optional) The working directory to run commands inside the container."
  type        = string
  default     = null
  nullable    = true
}

################################################################################
# Task Configuration
################################################################################

variable "ipc_mode" {
  description = "(Optional) IPC resource namespace to be used for the containers in the task. (`host`|`task`|`none`)."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition     = var.ipc_mode == null || try(contains(["host", "task", "none"], var.ipc_mode), false)
    error_message = "The 'ipc_mode' must be one of 'host', 'task', or 'none'."
  }
}

variable "pid_mode" {
  description = "(Optional) Process namespace to use for the containers in the task. (`host`|`task`)."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition     = var.pid_mode == null || try(contains(["host", "task"], var.pid_mode), false)
    error_message = "The 'pid_mode' must be one of 'host' or 'task'."
  }
}

variable "ephemeral_storage" {
  description = <<-EOT
  (Optional) Configuration block for Fargate task ephemeral storage (min 21 GiB).
    (Required) `size_in_gib`: The size (in GiB) of the ephemeral storage.
  EOT
  type = object({
    size_in_gib = number
  })
  default  = null
  nullable = true
}

variable "volumes" {
  description = <<-EOT
  (Optional) Configuration block for volumes that containers in your task may use.
    (Required) `name`: The name of the volume.
    (Optional) `host_path`: The path on the host container instance that is presented to the container.
    (Optional) `configure_at_launch`: Whether to configure the volume at launch.

    (Optional) `docker_volume_configuration`: Configuration block for Docker volumes.
      (Optional) `autoprovision`: If this value is `true`, then the Docker volume is created if it doesn't already exist.
      (Optional) `driver`: The Docker volume driver to use.
      (Optional) `driver_opts`: A map of Docker driver options to pass to the driver.
      (Optional) `labels`: A map of custom metadata to add to the volume.
      (Optional) `scope`: The scope of the volume.

    (Optional) `efs_volume_configuration`: Configuration block for Amazon EFS volumes.
      (Required) `file_system_id`: The ID of the Amazon EFS file system.
      (Optional) `root_directory`: The path on the Amazon EFS file system to mount the volume.
      (Optional) `transit_encryption`: The transit encryption mode.
      (Optional) `transit_encryption_port`: The port on the Amazon EFS file system that the container uses to connect to the Amazon EFS server.
      (Optional) `authorization_config`: Configuration block for authorization for the Amazon EFS file system.
        (Optional) `access_point_id`: The ID of the access point, if you are using Amazon EFS access points to enforce a root user.
        (Optional) `iam`: Whether to enable the IAM role.
  EOT
  type = list(object({
    name                = string
    host_path           = optional(string)
    configure_at_launch = optional(bool)
    docker_volume_configuration = optional(object({
      autoprovision = optional(bool, false)
      driver        = optional(string)
      driver_opts   = optional(map(string))
      labels        = optional(map(string))
      scope         = optional(string, "task")
    }))
    efs_volume_configuration = optional(object({
      file_system_id          = string
      root_directory          = optional(string, "/")
      transit_encryption      = optional(string, "DISABLED")
      transit_encryption_port = optional(number)
      authorization_config = optional(object({
        access_point_id = optional(string)
        iam             = optional(string, "DISABLED")
      }))
    }))
  }))
  default  = []
  nullable = false
}

variable "task_iam_role_arn" {
  description = "(Optional) The ARN of the IAM role that the task will use."
  type        = string
  default     = null
  nullable    = true
}

variable "task_exec_iam_role_arn" {
  description = "(Optional) The ARN of the IAM role that the task execution will use."
  type        = string
  default     = null
  nullable    = true
}

################################################################################
# Tags
################################################################################

variable "tags" {
  description = "(Optional) A map of tags to add to all resources created by this module (e.g., IAM roles, task definition)."
  type        = map(string)
  default     = {}
  nullable    = false
}
