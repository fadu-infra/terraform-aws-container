variable "operating_system_family" {
  description = "(Optional) The OS family for task"
  type        = string
  default     = "LINUX"
}

################################################################################
# Container Definition
################################################################################

variable "command" {
  description = "The command that's passed to the container"
  type        = list(string)
  default     = []
}

variable "cpu" {
  description = "(Optional) The number of cpu units to reserve for the container. This is optional for tasks using Fargate launch type and the total amount of `cpu` of all containers in a task will need to be lower than the task-level cpu value"
  type        = number
  default     = null
}

variable "dependencies" {
  description = "(Optional) The dependencies defined for container startup and shutdown. A container can contain multiple dependencies. When a dependency is defined for container startup, for container shutdown it is reversed. The condition can be one of START, COMPLETE, SUCCESS or HEALTHY"
  type = list(object({
    condition     = string
    containerName = string
  }))
  default = []
}

variable "disable_networking" {
  description = "(Optional) When this parameter is true, networking is disabled within the container"
  type        = bool
  default     = null
}

variable "dns_search_domains" {
  description = "(Optional) Container DNS search domains. A list of DNS search domains that are presented to the container"
  type        = list(string)
  default     = []
}

variable "dns_servers" {
  description = "(Optional) Container DNS servers. This is a list of strings specifying the IP addresses of the DNS servers"
  type        = list(string)
  default     = []
}

variable "docker_labels" {
  description = "(Optional) A key/value map of labels to add to the container"
  type        = map(string)
  default     = {}
}

variable "docker_security_options" {
  description = "(Optional) A list of strings to provide custom labels for SELinux and AppArmor multi-level security systems. This field isn't valid for containers in tasks using the Fargate launch type"
  type        = list(string)
  default     = []
}

variable "enable_execute_command" {
  description = "(Optional) Specifies whether to enable Amazon ECS Exec for the tasks within the service"
  type        = bool
  default     = false
}

variable "entrypoint" {
  description = "(Optional) The entry point that is passed to the container"
  type        = list(string)
  default     = []
}

variable "environment" {
  description = "(Optional) The environment variables to pass to the container"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "environment_files" {
  description = "(Optional) A list of files containing the environment variables to pass to a container"
  type = list(object({
    value = string
    type  = string
  }))
  default = []
}

variable "essential" {
  description = "(Optional) If the `essential` parameter of a container is marked as `true`, and that container fails or stops for any reason, all other containers that are part of the task are stopped"
  type        = bool
  default     = null
}

variable "extra_hosts" {
  description = "(Optional) A list of hostnames and IP address mappings to append to the `/etc/hosts` file on the container"
  type = list(object({
    hostname  = string
    ipAddress = string
  }))
  default = []
}

variable "firelens_configuration" {
  description = <<-EOT
    (Optional) The FireLens configuration for the container, used to specify and configure a log router for container logs. For more details, refer to the Amazon ECS Developer Guide on Custom Log Routing.
    - `options`: (Optional) A map of key-value pairs to configure the log router. These options allow customization of the log routing behavior.
    - `type`: (Optional) The log router to use. Valid values are `fluentd` or `fluentbit`.
  EOT
  type = object({
    options = optional(map(string))
    type    = optional(string)
  })
  default = {}
}

variable "health_check" {
  description = "(Optional) The container health check command and associated configuration parameters for the container. See [HealthCheck](https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_HealthCheck.html)"
  type = object({
    command     = optional(list(string))
    interval    = optional(number)
    timeout     = optional(number)
    retries     = optional(number)
    startPeriod = optional(number)
  })
  default = {}
}

variable "hostname" {
  description = "(Optional) The hostname to use for your container"
  type        = string
  default     = null
}

variable "image" {
  description = "(Optional) The image used to start a container. This string is passed directly to the Docker daemon. By default, images in the Docker Hub registry are available. Other repositories are specified with either `repository-url/image:tag` or `repository-url/image@digest`"
  type        = string
  default     = null
}

variable "interactive" {
  description = "(Optional) When this parameter is `true`, you can deploy containerized applications that require `stdin` or a `tty` to be allocated"
  type        = bool
  default     = false
}

variable "links" {
  description = "(Optional) The links parameter allows containers to communicate with each other without the need for port mappings. This parameter is only supported if the network mode of a task definition is `bridge`"
  type        = list(string)
  default     = []
}

variable "linux_parameters" {
  description = <<-EOT
    (Optional) Linux-specific modifications that are applied to the container, such as Linux kernel capabilities.
    This includes:
    - capabilities: The Linux capabilities for the container that are added to or dropped from the default configuration provided by Docker.
    - devices: Any host devices to expose to the container.
    - initProcessEnabled: Run an init process inside the container that forwards signals and reaps processes.
    - maxSwap: The total amount of swap memory (in MiB) a container can use.
    - sharedMemorySize: The size (in MiB) of the /dev/shm volume.
    - swappiness: Tune a container's memory swappiness behavior.
    - tmpfs: The container path, mount options, and size (in MiB) of the tmpfs mount.

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
  default = {}
}

variable "log_configuration" {
  description = "(Optional) The log configuration for the container. For more information see [LogConfiguration](https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_LogConfiguration.html)"
  type        = any
  default     = {}
}

variable "memory" {
  description = "(Optional) The amount (in MiB) of memory to present to the container. If your container attempts to exceed the memory specified here, the container is killed. The total amount of memory reserved for all containers within a task must be lower than the task `memory` value, if one is specified"
  type        = number
  default     = null

  validation {
    condition     = var.memory == null || var.memory >= 6
    error_message = "The memory must be at least 6 MiB."
  }
}

variable "memory_reservation" {
  description = "(Optional) The soft limit (in MiB) of memory to reserve for the container. When system memory is under heavy contention, Docker attempts to keep the container memory to this soft limit. However, your container can consume more memory when it needs to, up to either the hard limit specified with the `memory` parameter (if applicable), or all of the available memory on the container instance"
  type        = number
  default     = null

  validation {
    condition     = var.memory_reservation == null || var.memory_reservation >= 6
    error_message = "The memory_reservation must be at least 6 MiB."
  }

  validation {
    condition     = var.memory == null || var.memory_reservation == null || var.memory > var.memory_reservation
    error_message = "If both memory and memory_reservation are specified, memory must be greater than memory_reservation."
  }
}

variable "mount_points" {
  description = "(Optional) The mount points for data volumes in your container"
  type = list(object({
    containerPath = string
    readOnly      = bool
    sourceVolume  = string
  }))
  default = []
}

variable "name" {
  description = "(Optional) The name of a container. If you're linking multiple containers together in a task definition, the name of one container can be entered in the links of another container to connect the containers. Up to 255 letters (uppercase and lowercase), numbers, underscores, and hyphens are allowed"
  type        = string
  default     = null
}

variable "port_mappings" {
  description = "(Optional) The list of port mappings for the container. Port mappings allow containers to access ports on the host container instance to send or receive traffic. For task definitions that use the awsvpc network mode, only specify the containerPort. The hostPort can be left blank or it must be the same value as the containerPort"
  type = list(object({
    containerPort      = number
    hostPort           = optional(number)
    protocol           = optional(string, "tcp")
    appProtocol        = optional(string)
    containerPortRange = optional(string)
    name               = optional(string)
  }))
  default = []
}

variable "privileged" {
  description = "(Optional) When this parameter is true, the container is given elevated privileges on the host container instance (similar to the root user)"
  type        = bool
  default     = false
}

variable "pseudo_terminal" {
  description = "(Optional) When this parameter is true, a `TTY` is allocated"
  type        = bool
  default     = false
}

variable "readonly_root_filesystem" {
  description = "(Optional) When this parameter is true, the container is given read-only access to its root file system"
  type        = bool
  default     = true
}

variable "repository_credentials" {
  description = "(Optional) Container repository credentials; required when using a private repo.  This map currently supports a single key; \"credentialsParameter\", which should be the ARN of a Secrets Manager's secret holding the credentials"
  type        = map(string)
  default     = {}
}

variable "resource_requirements" {
  description = "(Optional) The type and amount of a resource to assign to a container. The only supported resource is a GPU"
  type = list(object({
    type  = string
    value = string
  }))
  default = []
}

variable "secrets" {
  description = "(Optional) The secrets to pass to the container. For more information, see [Specifying Sensitive Data](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/specifying-sensitive-data.html) in the Amazon Elastic Container Service Developer Guide"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

variable "start_timeout" {
  description = "(Optional) Time duration (in seconds) to wait before giving up on resolving dependencies for a container"
  type        = number
  default     = 30

  validation {
    condition     = var.start_timeout >= 2 && var.start_timeout <= 120
    error_message = "The start_timeout must be between 2 and 120 seconds."
  }
}

variable "stop_timeout" {
  description = "(Optional) Time duration (in seconds) to wait before the container is forcefully killed if it doesn't exit normally on its own"
  type        = number
  default     = 120

  validation {
    condition     = var.stop_timeout >= 2 && var.stop_timeout <= 120
    error_message = "The stop_timeout must not exceed 120 seconds."
  }
}

variable "system_controls" {
  description = "(Optional) A list of namespaced kernel parameters to set in the container"
  type = list(object({
    namespace = string
    value     = string
  }))
  default = []
}

variable "ulimits" {
  description = "(Optional) A list of ulimits to set in the container. If a ulimit value is specified in a task definition, it overrides the default values set by Docker"
  type = list(object({
    hardLimit = number
    name      = string
    softLimit = number
  }))
  default = []

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
}

variable "volumes_from" {
  description = "(Optional) Data volumes to mount from another container"
  type        = list(any)
  default     = []
}

variable "working_directory" {
  description = "(Optional) The working directory to run commands inside the container"
  type        = string
  default     = null
}

################################################################################
# CloudWatch Log Group
################################################################################

variable "service" {
  description = "(Optional) The name of the service that the container definition is associated with"
  type        = string
  default     = ""
}

variable "enable_cloudwatch_logging" {
  description = "(Optional) Determines whether CloudWatch logging is configured for this container definition. Set to `false` to use other logging drivers"
  type        = bool
  default     = true
}

variable "create_cloudwatch_log_group" {
  description = "(Optional) Determines whether a log group is created by this module. If not, AWS will automatically create one if logging is enabled"
  type        = bool
  default     = true
}

variable "cloudwatch_log_group_name" {
  description = "(Optional) Custom name of CloudWatch log group for a service associated with the container definition"
  type        = string
  default     = ""
  nullable    = false
}

variable "cloudwatch_log_group_use_name_prefix" {
  description = "(Optional) Determines whether the log group name should be used as a prefix"
  type        = bool
  default     = false
}

variable "cloudwatch_log_group_retention_in_days" {
  description = "(Optional) Number of days to retain log events. Default is 30 days"
  type        = number
  default     = 30
}

variable "cloudwatch_log_group_kms_key_id" {
  description = "(Optional) If a KMS Key ARN is set, this key will be used to encrypt the corresponding log group. Please be sure that the KMS Key has an appropriate key policy (https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html)"
  type        = string
  default     = null
}

variable "tags" {
  description = "(Optional) A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
