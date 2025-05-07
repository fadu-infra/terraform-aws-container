variable "operating_system_family" {
  description = "(Optional) The OS family for task"
  type        = string
  default     = "LINUX"
  nullable    = false

  validation {
    condition     = contains(["LINUX", "WINDOWS_SERVER_2019_FULL", "WINDOWS_SERVER_2019_CORE", "WINDOWS_SERVER_2022_FULL", "WINDOWS_SERVER_2022_CORE"], var.operating_system_family)
    error_message = "The operating_system_family must be one of: LINUX, WINDOWS_SERVER_2019_FULL, WINDOWS_SERVER_2019_CORE, WINDOWS_SERVER_2022_FULL, WINDOWS_SERVER_2022_CORE."
  }
}

################################################################################
# Container Definition
################################################################################

variable "command" {
  description = "(Optional) The command that's passed to the container"
  type        = list(string)
  default     = null
  nullable    = true
}

variable "container_cpu" {
  description = "(Optional) The number of cpu units to reserve for the container."
  type        = number
  default     = null
  nullable    = true
}

variable "dependencies" {
  description = "(Optional) The dependencies defined for container startup and shutdown. A container can contain multiple dependencies. When a dependency is defined for container startup, for container shutdown it is reversed. The condition can be one of START, COMPLETE, SUCCESS or HEALTHY"
  type = list(object({
    condition     = string
    containerName = string
  }))
  default  = []
  nullable = false
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
  description = "(Optional) A key/value map of labels to add to the container"
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "docker_security_options" {
  description = "(Optional) A list of strings to provide custom labels for SELinux and AppArmor multi-level security systems. This field isn't valid for containers in tasks using the Fargate launch type"
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
  description = "(Optional) Specifies whether to enable Amazon ECS Exec for the tasks within the service"
  type        = bool
  default     = false
  nullable    = false
}

variable "entrypoint" {
  description = "(Optional) The entry point that is passed to the container"
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

variable "essential" {
  description = "(Optional) If the `essential` parameter of a container is marked as `true`, and that container fails or stops for any reason, all other containers that are part of the task are stopped"
  type        = bool
  default     = false
  nullable    = false
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
  (Optional) The container health check command and associated configuration parameters for the container. See [HealthCheck](https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_HealthCheck.html)
    (Optional) `command`: The command that the container runs to determine if it is healthy.
    (Optional) `interval`: The time period in seconds between each health check execution.
    (Optional) `timeout`: The time period in seconds to wait for a health check to succeed.
    (Optional) `retries`: The number of times to retry a failed health check before the container is considered unhealthy.
    (Optional) `startPeriod`: The time period in seconds to wait for a health check to get a response from the command.
  EOT
  type = object({
    command     = optional(list(string))
    interval    = optional(number)
    timeout     = optional(number)
    retries     = optional(number)
    startPeriod = optional(number)
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

variable "image" {
  description = "(Optional) The image used to start a container. This string is passed directly to the Docker daemon. By default, images in the Docker Hub registry are available. Other repositories are specified with either `repository-url/image:tag` or `repository-url/image@digest`. Up to 255 letters (uppercase and lowercase), numbers, hyphens, underscores, colons, periods, forward slashes, and number signs are allowed. This parameter maps to Image in the docker container create command and the IMAGE parameter of docker run."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition     = var.image == null || length(regexall("^[a-zA-Z0-9-_:/.#]{1,255}$", var.image)) > 0
    error_message = "The image must be between 1 and 255 characters and can only contain letters, numbers, hyphens, underscores, colons, periods, forward slashes, and number signs."
  }
}

variable "interactive" {
  description = "(Optional) When this parameter is `true`, you can deploy containerized applications that require `stdin` or a `tty` to be allocated"
  type        = bool
  default     = false
  nullable    = false
}

variable "links" {
  description = "(Optional) The links parameter allows containers to communicate with each other without the need for port mappings. This parameter is only supported if the network mode of a task definition is bridge. The name:internalName construct is analogous to name:alias in Docker links. Up to 255 letters (uppercase and lowercase), numbers, underscores, and hyphens are allowed. This parameter maps to Links in the docker container create command and the --link option to docker run."
  type        = list(string)
  default     = []
  nullable    = false

  validation {
    condition = length(var.links) == 0 || alltrue([
      for link in var.links :
      length(regexall("^[a-zA-Z0-9-_]{1,255}:[a-zA-Z0-9-_]{1,255}$", link)) > 0
    ])
    error_message = "Each link must be in the format 'name:internalName' and can only contain letters, numbers, hyphens, and underscores, up to 255 characters for each part."
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
    maxSwap          = optional(number)
    sharedMemorySize = optional(number)
    swappiness       = optional(number)
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
  (Optional) The log configuration for the container. For more information see [LogConfiguration](https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_LogConfiguration.html)
    (Optional) `logDriver`: The log driver to use for the container.
    (Optional) `options`: The configuration options to send to the log driver.
    (Optional) `secretOptions`: The secrets to pass to the log configuration.
  EOT
  type = object({
    logDriver = optional(string)
    options   = optional(map(string))
    secretOptions = optional(list(object({
      name      = string
      valueFrom = string
    })))
  })
  default  = {}
  nullable = false
}

variable "container_memory" {
  description = "(Optional) The amount (in MiB) of memory to present to the container."
  type        = number
  default     = null
  nullable    = true

  validation {
    condition     = var.container_memory == null || try(var.container_memory >= 6, false)
    error_message = "The container_memory must be at least 6 MiB."
  }
}

variable "memory_reservation" {
  description = "(Optional) The soft limit (in MiB) of memory to reserve for the container. When system memory is under heavy contention, Docker attempts to keep the container memory to this soft limit. However, your container can consume more memory when it needs to, up to either the hard limit specified with the `memory` parameter (if applicable), or all of the available memory on the container instance"
  type        = number
  default     = null
  nullable    = true

  validation {
    condition     = var.memory_reservation == null || try(var.memory_reservation >= 6, false)
    error_message = "The memory_reservation must be at least 6 MiB."
  }

  validation {
    condition     = var.container_memory == null || var.memory_reservation == null || try(var.container_memory > var.memory_reservation, false)
    error_message = "If both container_memory and memory_reservation are specified, container_memory must be greater than memory_reservation."
  }
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
    readOnly      = bool
    sourceVolume  = string
  }))
  default  = []
  nullable = false
}

variable "name" {
  description = "(Optional) The name of a container. If you're linking multiple containers together in a task definition, the name of one container can be entered in the links of another container to connect the containers. Up to 255 letters (uppercase and lowercase), numbers, underscores, and hyphens are allowed"
  type        = string
  default     = null
  nullable    = true

  validation {
    condition     = var.name == null || length(regexall("^[a-zA-Z0-9-_]{1,255}$", var.name)) > 0
    error_message = "The container name must be between 1 and 255 characters and can only contain letters, numbers, hyphens, and underscores."
  }
}

variable "port_mappings" {
  description = <<-EOT
  (Optional) The list of port mappings for the container. Port mappings allow containers to access ports on the host container instance to send or receive traffic. For task definitions that use the awsvpc network mode, only specify the containerPort. The hostPort can be left blank or it must be the same value as the containerPort
    (Optional) `containerPort`: The port number on the container that is used with the network protocol.
    (Optional) `hostPort`: The port number on the host that is used with the network protocol.
    (Optional) `protocol`: The protocol used for the port mapping.
    (Optional) `appProtocol`: The application protocol to use for the port mapping.
  EOT
  type = list(object({
    containerPort      = number
    hostPort           = optional(number)
    protocol           = optional(string, "tcp")
    appProtocol        = optional(string)
    containerPortRange = optional(string)
    name               = optional(string)
  }))
  default  = []
  nullable = false
}

variable "privileged" {
  description = "(Optional) When this parameter is true, the container is given elevated privileges on the host container instance (similar to the root user)"
  type        = bool
  default     = false
  nullable    = false
}

variable "pseudo_terminal" {
  description = "(Optional) When this parameter is true, a `TTY` is allocated"
  type        = bool
  default     = false
  nullable    = false
}

variable "readonly_root_filesystem" {
  description = "(Optional) When this parameter is true, the container is given read-only access to its root file system"
  type        = bool
  default     = true
  nullable    = false
}

variable "repository_credentials" {
  description = "(Optional) Container repository credentials; required when using a private repo.  This map currently supports a single key; \"credentialsParameter\", which should be the ARN of a Secrets Manager's secret holding the credentials"
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "resource_requirements" {
  description = <<-EOT
  (Optional) The type and amount of a resource to assign to a container. The only supported resource is a GPU
    (Optional) `type`: The type of resource to assign to the container
    (Optional) `value`: The value of the resource
  EOT
  type = list(object({
    type  = string
    value = string
  }))
  default  = []
  nullable = false
}

variable "secrets" {
  description = <<-EOT
  (Optional) The secrets to pass to the container. For more information, see [Specifying Sensitive Data](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/specifying-sensitive-data.html) in the Amazon Elastic Container Service Developer Guide
    (Optional) `name`: The name of the secret to pass to the container
    (Optional) `valueFrom`: The value from the secret to pass to the container
  EOT
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default  = []
  nullable = false
}

variable "start_timeout" {
  description = "(Optional) Time duration (in seconds) to wait before giving up on resolving dependencies for a container"
  type        = number
  default     = 30
  nullable    = false

  validation {
    condition     = var.start_timeout >= 2 && var.start_timeout <= 120
    error_message = "The start_timeout must be between 2 and 120 seconds."
  }
}

variable "stop_timeout" {
  description = "(Optional) Time duration (in seconds) to wait before the container is forcefully killed if it doesn't exit normally on its own"
  type        = number
  default     = 120
  nullable    = false

  validation {
    condition     = var.stop_timeout >= 2 && var.stop_timeout <= 120
    error_message = "The stop_timeout must not exceed 120 seconds."
  }
}

variable "system_controls" {
  description = <<-EOT
  (Optional) A list of namespaced kernel parameters to set in the container
    (Optional) `namespace`: The namespace to set the kernel parameter in
    (Optional) `value`: The value of the kernel parameter
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
    (Optional) `hardLimit`: The hard limit for the ulimit
    (Optional) `name`: The name of the ulimit
    (Optional) `softLimit`: The soft limit for the ulimit
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
    error_message = "Each ulimit must have a valid name. Valid names are: core, cpu, data, fsize, locks, memlock, msgqueue, nice, nofile, nproc, rss, rtprio, rttime, sigpending, stack."
  }

  validation {
    condition = alltrue([
      for ulimit in var.ulimits : ulimit.hardLimit >= ulimit.softLimit
    ])
    error_message = "The hardLimit must be greater than or equal to the softLimit for each ulimit."
  }
}

variable "user" {
  description = "(Optional) The user to run as inside the container. Can be any of these formats: user, user:group, uid, uid:gid, user:gid, uid:group. The default (null) will use the container's configured `USER` directive or root if not set"
  type        = string
  default     = null
  nullable    = true
}

variable "volumes_from" {
  description = "(Optional) Data volumes to mount from another container"
  type        = list(any)
  default     = []
  nullable    = false
}

variable "working_directory" {
  description = "(Optional) The working directory to run commands inside the container"
  type        = string
  default     = null
  nullable    = true
}

################################################################################
# CloudWatch Log Group
################################################################################

variable "service" {
  description = "(Optional) The name of the service that the container definition is associated with"
  type        = string
  default     = ""
  nullable    = false
}

variable "cloudwatch_log_group_config" {
  description = <<-EOT
  (Optional) Configuration for the CloudWatch log group associated with the container definition. This includes:
    (Optional) `enable_logging`: Determines whether CloudWatch logging is configured for this container definition. Set to `false` to use other logging drivers.
    (Optional) `create_log_group`: Determines whether a log group is created by this module. If not, AWS will automatically create one if logging is enabled.
    (Optional) `log_group_name`: Custom name of CloudWatch log group for a service associated with the container definition.
    (Optional) `use_name_prefix`: Determines whether the log group name should be used as a prefix.
    (Optional) `retention_in_days`: Number of days to retain log events. Default is 30 days.
    (Optional) `kms_key_id`: If a KMS Key ARN is set, this key will be used to encrypt the corresponding log group. Please be sure that the KMS Key has an appropriate key policy (https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html).
  EOT
  type = object({
    enable_logging    = bool
    create_log_group  = bool
    log_group_name    = optional(string)
    use_name_prefix   = bool
    retention_in_days = number
    kms_key_id        = optional(string)
  })
  default = {
    enable_logging    = true
    create_log_group  = true
    use_name_prefix   = false
    retention_in_days = 30
  }
  nullable = false
}

variable "task_tags" {
  description = "(Optional) A map of additional tags to add to the task definition/set created"
  type        = map(string)
  default     = {}
  nullable    = false
}

################################################################################
# Task Definition
################################################################################

variable "task_cpu" {
  description = "(Optional) The number of cpu units to reserve for the task."
  type        = number
  default     = null
  nullable    = true
}

variable "task_memory" {
  description = "(Optional) The amount (in MiB) of memory to present to the task."
  type        = number
  default     = null
  nullable    = true
}

variable "ephemeral_storage" {
  description = <<-EOT
  (Optional) Configuration block for ephemeral storage. This parameter is used to expand the total amount of ephemeral storage available, beyond the default amount, for tasks hosted on AWS Fargate.
    (Required) `size_in_gib` - The amount of ephemeral storage to allocate for the task in GiB (21 - 200).
  EOT
  type = object({
    size_in_gib = number
  })
  default = {
    size_in_gib = 21
  }
  nullable = false
}

variable "family" {
  description = "(Required) A unique name for your task definition"
  type        = string
  default     = null
  nullable    = true
}

variable "ipc_mode" {
  description = "(Optional) IPC resource namespace to be used for the containers in the task. The valid values are `host`, `task`, and `none`. Not supported in Fargate."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition     = var.ipc_mode == null || try(contains(["host", "task", "none"], var.ipc_mode), false)
    error_message = "The 'ipc_mode' must be one of 'host', 'task', or 'none'."
  }
}

variable "network_mode" {
  description = "(Optional) Docker networking mode to use for the containers in the task. Valid values are `none`, `bridge`, `awsvpc`, and `host`"
  type        = string
  default     = "awsvpc"
  nullable    = false

  validation {
    condition     = var.network_mode == null || try(contains(["none", "bridge", "awsvpc", "host"], var.network_mode), false)
    error_message = "The 'network_mode' must be one of 'none', 'bridge', 'awsvpc', or 'host'."
  }
}

variable "pid_mode" {
  description = "(Optional) Process namespace to use for the containers in the task. The valid values are `host` and `task`"
  type        = string
  default     = null
  nullable    = true

  validation {
    condition     = contains(["host", "task"], var.pid_mode)
    error_message = "The 'pid_mode' must be one of 'host' or 'task'."
  }
}

variable "task_definition_placement_constraints" {
  description = <<-EOT
  (Optional) Configuration block for rules that are taken into consideration during task placement (up to max of 10). This is set at the task definition. Supports the following:
    (Optional) `expression` - Cluster Query Language expression to apply to the constraint. For more information, see Cluster Query Language in the Amazon EC2 Container Service Developer Guide.
    (Required) `type` - Type of constraint. Use `memberOf` to restrict selection to a group of valid candidates. Note that `distinctInstance` is not supported in task definitions.
  EOT
  type = list(object({
    expression = optional(string, null)
    type       = string
  }))
  default  = []
  nullable = false
}

/*
variable "proxy_configuration" {
  description = "Configuration block for the App Mesh proxy"
  type        = any
  default     = {}
}
*/

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

variable "runtime_platform" {
  description = <<-EOT
  (Optional) Configuration block for `runtime_platform` that containers in your task may use.
    (Optional) `operating_system_family` - If the `requires_compatibilities` is `FARGATE`, this field is required; must be set to a valid option from the operating system family in the runtime platform setting.
    (Optional) `cpu_architecture` - Must be set to either `X86_64` or `ARM64`.
  EOT
  type = object({
    operating_system_family = optional(string, "LINUX")
    cpu_architecture        = optional(string, "X86_64")
  })
  nullable = false
  default = {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

variable "skip_destroy" {
  description = "(Optional) If true, the task is not deleted when the service is deleted"
  type        = bool
  default     = null
  nullable    = true
}

variable "volume" {
  description = <<-EOT
  (Optional) Configuration block for volumes that containers in your task may use. Supports the following configurations:
    (Required) `name` - Name of the volume. This name is referenced in the sourceVolume parameter of container definition in the mountPoints section.
    (Optional) `docker_volume_configuration` - Configuration block to configure a Docker volume. Docker volumes are only supported when using the EC2 launch type or external instances.
      (Optional) `autoprovision` - Whether to automatically provision an EBS volume. This field is only used if the scope is 'shared'.
      (Optional) `driver_opts` - Map of Docker driver specific options.
      (Optional) `driver` - Docker volume driver to use. The driver value must match the driver name provided by Docker because it is used for task placement.
      (Optional) `labels` - Map of custom metadata to add to your Docker volume.
      (Optional) `scope` - Scope for the Docker volume, which determines its lifecycle, either 'task' or 'shared'. Docker volumes that are scoped to a task are automatically provisioned when the task starts and destroyed when the task stops. Docker volumes that are scoped as shared persist after the task stops.
    (Optional) `efs_volume_configuration` - Configuration block for an EFS volume.
      (Optional) `file_system_id` - The ID of the EFS file system.
      (Optional) `root_directory` - The path on the EFS file system to mount the volume.
      (Optional) `transit_encryption` - Whether to enable encryption for the EFS volume. Valid values are `ENABLED` and `DISABLED`.
      (Optional) `transit_encryption_port` - The port on the container to connect to the EFS file system.
      (Optional) `authorization_config` - Configuration block for authorization for the EFS volume.
        (Optional) `access_point_id` - The ID of the access point to use for the EFS volume.
        (Optional) `iam` - Whether to use the IAM role specified in the task definition. Valid values are `ENABLED` and `DISABLED`.
    (Optional) `host_path` - Path on the host container instance that is presented to the container.
    (Optional) `configure_at_launch` - Whether the volume should be configured at launch time. This is used to create Amazon EBS volumes for standalone tasks or tasks created as part of a service.
  EOT
  type = map(object({
    docker_volume_configuration = optional(object({
      autoprovision = optional(bool)
      driver_opts   = optional(map(string))
      driver        = optional(string)
      labels        = optional(map(string))
      scope         = optional(string)
    }))
    efs_volume_configuration = optional(object({
      file_system_id          = string
      root_directory          = optional(string)
      transit_encryption      = optional(string, "DISABLED")
      transit_encryption_port = optional(number)
      authorization_config = optional(object({
        access_point_id = optional(string)
        iam             = optional(string, "DISABLED")
      }))
    }))
    host_path           = optional(string, null)
    configure_at_launch = optional(bool, false)
    name                = string
  }))
  default  = {}
  nullable = false
}

################################################################################
# Task Execution - IAM Role
################################################################################

variable "task_exec_iam_role_arn" {
  description = "(Optional) Existing IAM role ARN. Required when `create_task_exec_iam_role` is `false`"
  type        = string
  default     = null
  nullable    = true
}

variable "create_task_exec_iam_role" {
  description = "(Optional) Determines whether the ECS task definition IAM role should be created"
  type        = bool
  default     = true
  nullable    = false
}

variable "task_exec_iam_role_name" {
  description = "(Optional) Name to use on IAM role created"
  type        = string
  default     = "default-task-exec-iam-role"
  nullable    = false
}

variable "task_exec_iam_role_use_name_prefix" {
  description = "(Optional) Determines whether the IAM role name (`task_exec_iam_role_name`) is used as a prefix"
  type        = bool
  default     = true
  nullable    = false
}

variable "task_exec_iam_role_path" {
  description = "(Optional) IAM role path"
  type        = string
  default     = null
  nullable    = true
}

variable "task_exec_iam_role_description" {
  description = "(Optional) Description of the role"
  type        = string
  default     = null
  nullable    = true
}

variable "task_exec_iam_role_permissions_boundary" {
  description = "(Optional) ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
  nullable    = true
}

variable "task_exec_iam_role_tags" {
  description = "(Optional) A map of additional tags to add to the IAM role created"
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "task_exec_iam_role_policies" {
  description = "(Optional) Map of IAM role policy ARNs to attach to the IAM role"
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "task_exec_iam_role_max_session_duration" {
  description = "(Optional) Maximum session duration (in seconds) for ECS task execution role. Default is 3600."
  type        = number
  default     = null
  nullable    = true
}

variable "create_task_exec_policy" {
  description = "(Optional) Determines whether the ECS task definition IAM policy should be created. This includes permissions included in AmazonECSTaskExecutionRolePolicy as well as access to secrets and SSM parameters"
  type        = bool
  default     = true
  nullable    = false
}

variable "task_exec_ssm_param_arns" {
  description = "(Optional) List of SSM parameter ARNs the task execution role will be permitted to get/read"
  type        = list(string)
  default     = ["arn:aws:ssm:*:*:parameter/*"]
  nullable    = false
}

variable "task_exec_secret_arns" {
  description = "(Optional) List of SecretsManager secret ARNs the task execution role will be permitted to get/read"
  type        = list(string)
  default     = ["arn:aws:secretsmanager:*:*:secret:*"]
  nullable    = false
}

variable "task_exec_iam_statements" {
  description = <<-EOT
  (Optional) A map of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for custom permission usage"
  Note: Same `iam_role_statements` variable configuration applies here.
  EOT
  type = map(object({
    sid           = optional(string)
    actions       = optional(list(string))
    not_actions   = optional(list(string))
    effect        = optional(string)
    resources     = optional(list(string))
    not_resources = optional(list(string))
    principals = optional(list(object({
      type        = string
      identifiers = list(string)
    })))
    not_principals = optional(list(object({
      type        = string
      identifiers = list(string)
    })))
    conditions = optional(list(object({
      test     = string
      values   = list(string)
      variable = string
    })))
  }))
  default  = {}
  nullable = false
}

variable "task_exec_iam_policy_path" {
  description = "(Optional) Path for the iam role"
  type        = string
  default     = null
  nullable    = true
}

################################################################################
# Tasks - IAM role
################################################################################

variable "tasks_iam_role_arn" {
  description = "(Optional) Existing IAM role ARN"
  type        = string
  default     = null
  nullable    = true
}

variable "create_tasks_iam_role" {
  description = "(Optional) Determines whether the ECS tasks IAM role should be created"
  type        = bool
  default     = true
  nullable    = false
}

variable "tasks_iam_role_name" {
  description = "(Optional) Name to use on IAM role created"
  type        = string
  default     = "default-tasks-iam-role"
  nullable    = false
}

variable "tasks_iam_role_use_name_prefix" {
  description = "(Optional) Determines whether the IAM role name (`tasks_iam_role_name`) is used as a prefix"
  type        = bool
  default     = true
  nullable    = false
}

variable "tasks_iam_role_path" {
  description = "(Optional) IAM role path"
  type        = string
  default     = null
  nullable    = true
}

variable "tasks_iam_role_description" {
  description = "(Optional) Description of the role"
  type        = string
  default     = null
  nullable    = true
}

variable "tasks_iam_role_permissions_boundary" {
  description = "(Optional) ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
  nullable    = true
}

variable "tasks_iam_role_tags" {
  description = "(Optional) A map of additional tags to add to the IAM role created"
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "tasks_iam_role_policies" {
  description = "(Optional) Map of IAM role policy ARNs to attach to the IAM role"
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "tasks_iam_role_statements" {
  description = <<-EOT
  (Optional) A map of IAM policy statements for custom permission usage. Each statement supports the following:
  Note: Same `iam_role_statements` variable configuration applies here.
  EOT
  type = map(object({
    sid           = optional(string)
    actions       = optional(list(string))
    not_actions   = optional(list(string))
    effect        = optional(string)
    resources     = optional(list(string))
    not_resources = optional(list(string))
    principals = optional(list(object({
      type        = string
      identifiers = list(string)
    })))
    not_principals = optional(list(object({
      type        = string
      identifiers = list(string)
    })))
    conditions = optional(list(object({
      test     = string
      values   = list(string)
      variable = string
    })))
  }))
  default  = {}
  nullable = false
}

variable "tags" {
  description = "(Optional) A map of tags to add to all resources"
  type        = map(string)
  default     = {}
  nullable    = false
}
