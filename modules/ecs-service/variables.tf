variable "create_service" {
  description = "(Optional) Determines whether service resource will be created (set to `false` in case you want to create task definition only)"
  type        = bool
  default     = true
  nullable    = false
}

variable "tags" {
  description = "(Optional) A map of tags to add to all resources"
  type        = map(string)
  default     = {}
  nullable    = false
}

################################################################################
# Service
################################################################################

variable "alarms" {
  description = <<-EOT
    (Optional) Information about the CloudWatch alarms. The alarms configuration block supports the following:
      (Required) `alarm_names` - One or more CloudWatch alarm names.
      (Optional) `enable` - Whether to use the CloudWatch alarm option in the service deployment process. Defaults to true.
      (Optional) `rollback` - Whether to configure Amazon ECS to roll back the service if a service deployment fails. Defaults to true.
  EOT
  type = list(object({
    alarm_names = list(string)
    enable      = optional(bool, true)
    rollback    = optional(bool, true)
  }))
  default = []
}

variable "capacity_provider_strategy" {
  description = <<-EOT
    (Optional) A map of capacity provider strategies for the ECS service. Each entry in the map should have the following keys:
      (Required) `capacity_provider` - The short name of the capacity provider.
      (Optional) `base` - The minimum number of tasks to run on the specified capacity provider. Defaults to null.
      (Required) `weight` - The relative percentage of the total number of launched tasks that should use the specified capacity provider.

    This variable allows you to specify how tasks are distributed across different capacity providers, which can be useful for balancing cost and performance.
  EOT

  type = map(object({
    capacity_provider = string
    base              = optional(number)
    weight            = number
  }))

  default = {}

  validation {
    condition     = alltrue([for cp in var.capacity_provider_strategy : cp.weight != null && cp.weight >= 0 && cp.weight <= 100])
    error_message = "Each 'weight' must be a number between 0 and 100, inclusive, and cannot be null."
  }
}

variable "cluster_arn" {
  description = "(Optional) ARN of the ECS cluster where the resources will be provisioned"
  type        = string
  default     = ""
  nullable    = false
}

variable "deployment_setting" {
  description = <<-EOT
    (Optional) Deployment settings including:
      (Optional) `circuit_breaker` - Configuration block for deployment circuit breaker
        (Optional) `enable` - Whether to enable the deployment circuit breaker. Defaults to false.
      (Optional) `maximum_percent` - Upper limit (as a percentage of the service's `desired_count`) of the number of running tasks that can be running in a service during a deployment
      (Optional) `minimum_healthy_percent` - Lower limit (as a percentage of the service's `desired_count`) of the number of running tasks that must remain running and healthy in a service during a deployment
  EOT

  type = object({
    circuit_breaker = optional(object({
      enable   = bool
      rollback = bool
    }))
    maximum_percent         = optional(number, 200)
    minimum_healthy_percent = optional(number, 66)
  })
  nullable = false
  default = {
    circuit_breaker = {
      enable   = false
      rollback = false
    }
    maximum_percent         = 200
    minimum_healthy_percent = 66
  }
}

variable "desired_count" {
  description = "(Optional) Number of instances of the task definition to place and keep running"
  type        = number
  default     = 1
}

variable "enable_ecs_managed_tags" {
  description = "(Optional) Specifies whether to enable Amazon ECS managed tags for the tasks within the service"
  type        = bool
  default     = true
}

variable "enable_execute_command" {
  description = "(Optional) Specifies whether to enable Amazon ECS Exec for the tasks within the service"
  type        = bool
  default     = false
}

variable "force_new_deployment" {
  description = "(Optional) Enable to force a new task deployment of the service. This can be used to update tasks to use a newer Docker image with same image/tag combination, roll Fargate tasks onto a newer platform version, or immediately deploy `ordered_placement_strategy` and `placement_constraints` updates"
  type        = bool
  default     = true
}

variable "health_check_grace_period_seconds" {
  description = "(Optional) Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown, up to 2147483647. Only valid for services configured to use load balancers"
  type        = number
  default     = 0
  nullable    = false

  validation {
    condition     = var.health_check_grace_period_seconds == null || var.health_check_grace_period_seconds <= 2147483647
    error_message = "The 'health_check_grace_period_seconds' must not exceed 2147483647."
  }
}

variable "launch_type" {
  description = "(Optional) Launch type on which to run your service. The valid values are `EC2`, `FARGATE`, and `EXTERNAL`. Defaults to `FARGATE`"
  type        = string
  default     = "FARGATE"
}

variable "load_balancers" {
  description = <<-EOT
    (Optional) Configuration block for load balancers. The configuration supports the following:
      (Required) `container_name` - The name of the container to associate with the load balancer.
      (Required) `container_port` - The port on the container to associate with the load balancer.
      (Optional) `elb_name` - The name of the Elastic Load Balancer.
      (Optional) `target_group_arn` - The ARN of the target group.
  EOT
  type = map(object({
    container_name   = string
    container_port   = number
    elb_name         = optional(string)
    target_group_arn = optional(string)
  }))
  default = {}
}

variable "name" {
  description = "(Required) Name of the service (up to 255 letters, numbers, hyphens, and underscores)"
  type        = string
  default     = ""
  nullable    = false
}

variable "network_configuration" {
  description = <<-EOT
    (Optional) Network configuration for the ECS service, including:
      (Optional) `assign_public_ip` - Assign a public IP address to the ENI (Fargate launch type only).
      (Optional) `security_group_ids` - List of security groups to associate with the task or service.
      (Required) `subnet_ids` - List of subnets to associate with the task or service.
  EOT

  type = object({
    assign_public_ip   = optional(bool, false)
    security_group_ids = optional(list(string), [])
    subnet_ids         = optional(list(string), [])
  })
  nullable = false
  default = {
    assign_public_ip   = false
    security_group_ids = []
    subnet_ids         = []
  }
}

variable "ordered_placement_strategy" {
  description = <<-EOT
    (Optional) Service level strategy rules that are taken into consideration during task placement. List from top to bottom in order of precedence.
      (Required) `type` - Type of placement strategy. Must be one of: `binpack`, `random`, or `spread`.
      (Optional) `field` - For the `spread` placement strategy, valid values are `instanceId` (or `host`, which has the same effect), or any platform or custom attribute that is applied to a container instance. For the `binpack` type, valid values are `memory` and `cpu`. For the `random` type, this attribute is not needed. For more information, see Placement Strategy.
  EOT
  type = map(object({
    type  = string
    field = string
  }))
  default = {}

  validation {
    condition = alltrue([
      for strategy in var.ordered_placement_strategy : (
        contains(["binpack", "random", "spread"], strategy.type) &&
        (
          (strategy.type == "spread" && contains(["instanceId", "host"], strategy.field)) ||
          (strategy.type == "binpack" && contains(["memory", "cpu"], strategy.field)) ||
          (strategy.type == "random" && strategy.field == "")
        )
      )
    ])
    error_message = "Each 'type' must be one of 'binpack', 'random', or 'spread'. For 'spread', 'field' must be 'instanceId', 'host', or a valid attribute. For 'binpack', 'field' must be 'memory' or 'cpu'. 'random' does not require a 'field'."
  }
}

variable "placement_constraints" {
  description = <<-EOT
    (Optional) Configuration block for rules that are taken into consideration during task placement (up to max of 10). This is set at the service level. Supports the following:
      (Optional) `expression` - Cluster Query Language expression to apply to the constraint. This is not required when the `type` is `distinctInstance`.
      (Required) `type` - Type of constraint. The only valid values at this time are `memberOf` and `distinctInstance`.
  EOT
  type = list(object({
    expression = optional(string)
    type       = string
  }))
  default = []

  validation {
    condition     = alltrue([for constraint in var.placement_constraints : contains(["memberOf", "distinctInstance"], constraint.type)])
    error_message = "Each 'type' must be either 'memberOf' or 'distinctInstance'."
  }
}

variable "platform_version" {
  description = "(Optional) Platform version on which to run your service. Only applicable for `launch_type` set to `FARGATE`. Defaults to `LATEST`"
  type        = string
  default     = null
  nullable    = true
}

variable "propagate_tags" {
  description = "(Optional) Specifies whether to propagate the tags from the task definition or the service to the tasks. The valid values are `SERVICE` and `TASK_DEFINITION`"
  type        = string
  default     = null
  nullable    = true
}

variable "scheduling_strategy" {
  description = <<-EOT
    (Optional) Scheduling strategy to use for the service. The valid values are `REPLICA` and `DAEMON`. Defaults to `REPLICA`.
    Note: Tasks using the Fargate launch type or the CODE_DEPLOY or EXTERNAL deployment controller types don't support the DAEMON scheduling strategy.
  EOT
  type        = string
  default     = "REPLICA"

  validation {
    condition     = contains(["REPLICA", "DAEMON"], var.scheduling_strategy)
    error_message = "The 'scheduling_strategy' must be either 'REPLICA' or 'DAEMON'."
  }
}

variable "service_connect_configuration" {
  description = <<-EOT
    (Optional) The ECS Service Connect configuration for this service to discover and connect to services, and be discovered by, and connected from, other services within a namespace.
      (Optional) `enabled` - Whether the service connect is enabled. Defaults to true.
      (Optional) `log_configuration` - Configuration block for logging
        (Optional) `log_driver` - The log driver to use for the container.
        (Optional) `options` - Key-value pairs to configure the log driver.
        (Optional) `secret_option` - Configuration block for secret options
          (Required) `name` - The name of the secret option.
          (Required) `value_from` - The ARN of the secret.
      (Optional) `namespace` - The namespace for the service connect.
      (Optional) `service` - Configuration block for the service
        (Optional) `client_alias` - Configuration block for client alias
          (Optional) `dns_name` - The DNS name for the client alias.
          (Required) `port` - The port for the client alias.
        (Optional) `discovery_name` - The discovery name for the service.
        (Optional) `ingress_port_override` - The ingress port override for the service.
        (Required) `port_name` - The port name for the service.
  EOT

  type = object({
    enabled = optional(bool, true)
    log_configuration = optional(object({
      log_driver = optional(string)
      options    = optional(map(string))
      secret_option = optional(list(object({
        name       = string
        value_from = string
      })))
    }))
    namespace = optional(string)
    service = optional(object({
      client_alias = optional(object({
        dns_name = optional(string)
        port     = number
      }))
      discovery_name        = optional(string)
      ingress_port_override = optional(number)
      port_name             = string
    }))
  })

  default = {}
}

variable "service_discovery_registries" {
  description = <<-EOT
    (Optional) Service discovery registries for the service. Supports the following:
      (Required) `registry_arn` - ARN of the Service Registry. The currently supported service registry is Amazon Route 53 Auto Naming Service (aws_service_discovery_service).
      (Optional) `port` - Port value used if your Service Discovery service specified an SRV record.
      (Optional) `container_port` - Port value, already specified in the task definition, to be used for your service discovery service.
    - `container_name`: (Optional) Container name value, already specified in the task definition, to be used for your service discovery service.
  EOT
  type = map(object({
    container_name = string
    container_port = number
    port           = number
    registry_arn   = string
  }))
  default = {}
}

variable "timeouts" {
  description = <<-EOT
    (Optional) Timeout configurations for the service operations. Supports the following:
      (Default 20m) `create` - Timeout for creating the service.
      (Default 20m) `update` - Timeout for updating the service.
      (Default 20m) `delete` - Timeout for deleting the service.
  EOT
  type = object({
    create = optional(string, "20m")
    update = optional(string, "20m")
    delete = optional(string, "20m")
  })
  nullable = false
  default  = {}
}

variable "triggers" {
  description = "(Optional) Map of arbitrary keys and values that, when changed, will trigger an in-place update (redeployment). Useful with `timestamp()`"
  type        = any
  default     = {}
}

variable "wait_for_steady_state" {
  description = "(Optional) If true, Terraform will wait for the service to reach a steady state before continuing. Default is `false`"
  type        = bool
  default     = null
  nullable    = true
}

variable "service_tags" {
  description = "(Optional) A map of additional tags to add to the service"
  type        = map(string)
  default     = {}
}

################################################################################
# Service - IAM Role
################################################################################

variable "create_iam_role" {
  description = "(Optional) Determines whether the ECS service IAM role should be created"
  type        = bool
  default     = true
}

variable "iam_role_arn" {
  description = <<-EOT
    (Optional) Existing IAM role ARN. Required if using a load balancer without awsvpc network mode.
    If awsvpc is used in task definition, do not specify. Defaults to the ECS service-linked role if available.
  EOT
  type        = string
  default     = null
}

variable "iam_role_name" {
  description = "(Optional) Name to use on IAM role created"
  type        = string
  default     = null
}

variable "iam_role_use_name_prefix" {
  description = "(Optional) Determines whether the IAM role name (`iam_role_name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "iam_role_path" {
  description = "(Optional) IAM role path"
  type        = string
  default     = null
}

variable "iam_role_description" {
  description = "(Optional) Description of the role"
  type        = string
  default     = null
}

variable "iam_role_permissions_boundary" {
  description = "(Optional) ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}

variable "iam_role_tags" {
  description = "A map of additional tags to add to the IAM role created"
  type        = map(string)
  default     = {}
}

variable "iam_role_statements" {
  description = <<-EOT
    (Optional) A map of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for custom permission usage.
      (Optional) `sid` - A unique identifier for the statement.
      (Required) `actions` - A list of actions that the statement allows or denies.
      (Optional) `not_actions` - A list of actions that are explicitly not allowed.
      (Required) `effect` - The effect of the statement, either `Allow` or `Deny`.
      (Required) `resources` - A list of resources to which the statement applies.d
      (Optional) `not_resources` - A list of resources that are explicitly not included.
      (Optional) `principals` - A list of principals to which the statement applies.
        (Optional) `type` - The type of principal.
        (Required) `identifiers` - The list of identifiers for the principal.
      (Optional) `not_principals` - A list of principals that are explicitly not included.
        (Optional) `type` - The type of principal.
        (Required) `identifiers` - The list of identifiers for the principal.
      (Optional) `conditions` - A list of conditions that must be met for the statement to apply.
        (Optional) `test` - The condition type.
        (Required) `values` - The list of values for the condition.
        (Optional) `variable` - The key name of the condition.
  EOT
  type = map(object({
    sid           = optional(string)
    actions       = list(string)
    not_actions   = optional(list(string))
    effect        = string
    resources     = list(string)
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
  default = {}
}

################################################################################
# Task Definition
################################################################################

variable "create_task_definition" {
  description = "(Optional) Determines whether to create a task definition or use existing/provided"
  type        = bool
  default     = true
}

variable "task_definition_arn" {
  description = "(Optional) Existing task definition ARN. Required when `create_task_definition` is `false`"
  type        = string
  default     = null
}

variable "container_definitions" {
  description = <<-EOT
    (Optional) A map of valid [container definitions](http://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_ContainerDefinition.html). Please note that you should only provide values that are part of the container definition document. The configuration supports the following:
      (Required) `name` - The name of the container.
      (Required) `image` - The image to use for the container.
      (Optional) `cpu` - The number of CPU units to reserve for the container.
      (Optional) `memory` - The amount of memory (in MiB) to reserve for the container.
      (Optional) `essential` - Whether the container is essential. Defaults to true.
      (Optional) `port_mappings` - A list of port mappings for the container. Each mapping supports:
        (Required) `container_port` - The port number on the container.
        (Optional) `host_port` - The port number on the host.
        (Optional) `protocol` - The protocol used for the port mapping. Defaults to "tcp".
      (Optional) `environment` - A list of environment variables for the container. Each variable supports:
        (Required) `name` - The name of the environment variable.
        (Required) `value` - The value of the environment variable.
      (Optional) `command` - The command to run inside the container.
      (Optional) `dependencies` - The dependencies for the container.
      (Optional) `disable_networking` - Whether to disable networking for the container.
      (Optional) `dns_search_domains` - A list of DNS search domains.
      (Optional) `dns_servers` - A list of DNS servers.
      (Optional) `docker_labels` - A map of Docker labels.
      (Optional) `docker_security_options` - A list of Docker security options.
      (Optional) `enable_execute_command` - Whether to enable execute command.
      (Optional) `entrypoint` - The entry point for the container.
      (Optional) `environment_files` - A list of environment files.
      (Optional) `extra_hosts` - A list of extra hosts.
      (Optional) `firelens_configuration` - FireLens configuration.
      (Optional) `health_check` - Health check configuration.
      (Optional) `hostname` - The hostname for the container.
      (Optional) `interactive` - Whether the container is interactive.
      (Optional) `links` - A list of links for the container.
      (Optional) `linux_parameters` - Linux parameters.
      (Optional) `log_configuration` - Log configuration.
      (Optional) `memory_reservation` - The amount of memory to reserve for the container.
      (Optional) `mount_points` - A list of mount points.
      (Optional) `privileged` - Whether the container is privileged.
      (Optional) `pseudo_terminal` - Whether to allocate a pseudo-TTY.
      (Optional) `readonly_root_filesystem` - Whether the root filesystem is read-only.
      (Optional) `repository_credentials` - Repository credentials.
      (Optional) `resource_requirements` - Resource requirements.
      (Optional) `secrets` - A list of secrets.
      (Optional) `start_timeout` - The start timeout for the container.
      (Optional) `stop_timeout` - The stop timeout for the container.
      (Optional) `system_controls` - System controls.
      (Optional) `ulimits` - Ulimits.
      (Optional) `user` - The user to run the container as.
      (Optional) `volumes_from` - A list of volumes to mount from another container.
      (Optional) `working_directory` - The working directory for the container.
      (Optional) `enable_cloudwatch_logging` - Whether to enable CloudWatch logging.
      (Optional) `create_cloudwatch_log_group` - Whether to create a CloudWatch log group.
      (Optional) `cloudwatch_log_group_name` - The name of the CloudWatch log group.
      (Optional) `cloudwatch_log_group_use_name_prefix` - Whether to use a name prefix for the CloudWatch log group.
      (Optional) `cloudwatch_log_group_retention_in_days` - The retention period for the CloudWatch log group.
      (Optional) `cloudwatch_log_group_kms_key_id` - The KMS key ID for the CloudWatch log group.
  EOT
  type = map(object({
    name      = string
    image     = string
    cpu       = optional(number)
    memory    = optional(number)
    essential = optional(bool, true)
    port_mappings = optional(list(object({
      container_port = number
      host_port      = optional(number)
      protocol       = optional(string, "tcp")
    })), [])
    environment = optional(list(object({
      name  = string
      value = string
    })), [])
    command                                = optional(list(string), [])
    dependencies                           = optional(list(string), [])
    disable_networking                     = optional(bool, null)
    dns_search_domains                     = optional(list(string), [])
    dns_servers                            = optional(list(string), [])
    docker_labels                          = optional(map(string), {})
    docker_security_options                = optional(list(string), [])
    enable_execute_command                 = optional(bool, null)
    entrypoint                             = optional(list(string), [])
    environment_files                      = optional(list(string), [])
    extra_hosts                            = optional(list(string), [])
    firelens_configuration                 = optional(map(string), {})
    health_check                           = optional(map(string), {})
    hostname                               = optional(string, null)
    interactive                            = optional(bool, false)
    links                                  = optional(list(string), [])
    linux_parameters                       = optional(map(string), {})
    log_configuration                      = optional(map(string), {})
    memory_reservation                     = optional(number, null)
    mount_points                           = optional(list(string), [])
    privileged                             = optional(bool, false)
    pseudo_terminal                        = optional(bool, false)
    readonly_root_filesystem               = optional(bool, true)
    repository_credentials                 = optional(map(string), {})
    resource_requirements                  = optional(list(string), [])
    secrets                                = optional(list(string), [])
    start_timeout                          = optional(number, 30)
    stop_timeout                           = optional(number, 120)
    system_controls                        = optional(list(string), [])
    ulimits                                = optional(list(string), [])
    user                                   = optional(string, "0")
    volumes_from                           = optional(list(string), [])
    working_directory                      = optional(string, null)
    enable_cloudwatch_logging              = optional(bool, true)
    create_cloudwatch_log_group            = optional(bool, true)
    cloudwatch_log_group_name              = optional(string, null)
    cloudwatch_log_group_use_name_prefix   = optional(bool, false)
    cloudwatch_log_group_retention_in_days = optional(number, 14)
    cloudwatch_log_group_kms_key_id        = optional(string, null)
  }))
  default = {}
}

variable "container_definition_defaults" {
  description = "(Optional) A map of default values for container definitions. The structure is the same as `container_definitions`. Refer to the `container_definitions` variable for details."
  type = map(object({
    name      = string
    image     = string
    cpu       = optional(number)
    memory    = optional(number)
    essential = optional(bool, true)
    port_mappings = optional(list(object({
      container_port = number
      host_port      = optional(number)
      protocol       = optional(string, "tcp")
    })), [])
    environment = optional(list(object({
      name  = string
      value = string
    })), [])
    command                                = optional(list(string), [])
    dependencies                           = optional(list(string), [])
    disable_networking                     = optional(bool, null)
    dns_search_domains                     = optional(list(string), [])
    dns_servers                            = optional(list(string), [])
    docker_labels                          = optional(map(string), {})
    docker_security_options                = optional(list(string), [])
    enable_execute_command                 = optional(bool, null)
    entrypoint                             = optional(list(string), [])
    environment_files                      = optional(list(string), [])
    extra_hosts                            = optional(list(string), [])
    firelens_configuration                 = optional(map(string), {})
    health_check                           = optional(map(string), {})
    hostname                               = optional(string, null)
    interactive                            = optional(bool, false)
    links                                  = optional(list(string), [])
    linux_parameters                       = optional(map(string), {})
    log_configuration                      = optional(map(string), {})
    memory_reservation                     = optional(number, null)
    mount_points                           = optional(list(string), [])
    privileged                             = optional(bool, false)
    pseudo_terminal                        = optional(bool, false)
    readonly_root_filesystem               = optional(bool, true)
    repository_credentials                 = optional(map(string), {})
    resource_requirements                  = optional(list(string), [])
    secrets                                = optional(list(string), [])
    start_timeout                          = optional(number, 30)
    stop_timeout                           = optional(number, 120)
    system_controls                        = optional(list(string), [])
    ulimits                                = optional(list(string), [])
    user                                   = optional(string, "0")
    volumes_from                           = optional(list(string), [])
    working_directory                      = optional(string, null)
    enable_cloudwatch_logging              = optional(bool, true)
    create_cloudwatch_log_group            = optional(bool, true)
    cloudwatch_log_group_name              = optional(string, null)
    cloudwatch_log_group_use_name_prefix   = optional(bool, false)
    cloudwatch_log_group_retention_in_days = optional(number, 14)
    cloudwatch_log_group_kms_key_id        = optional(string, null)
  }))
  default = {}
}

variable "cpu" {
  description = "(Optional) Number of cpu units used by the task. If the `requires_compatibilities` is `FARGATE` this field is required"
  type        = number
  default     = 1024
}

variable "ephemeral_storage" {
  description = <<-EOT
    (Optional) Configuration block for ephemeral storage. Supports the following:
    (Required) `size_in_gib` - The amount of ephemeral storage to allocate for the task in GiB.
  EOT

  type = object({
    size_in_gib = number
  })
  default = {
    size_in_gib = 20
  }
}

variable "family" {
  description = "(Required) A unique name for your task definition"
  type        = string
  default     = null
}

/*
variable "inference_accelerator" {
  description = "Configuration block(s) with Inference Accelerators settings"
  type        = any
  default     = {}
}
*/

variable "ipc_mode" {
  description = "(Optional) IPC resource namespace to be used for the containers in the task. The valid values are `host`, `task`, and `none`"
  type        = string
  default     = null

  validation {
    condition     = var.ipc_mode == null || contains(["host", "task", "none"], var.ipc_mode)
    error_message = "The 'ipc_mode' must be one of 'host', 'task', or 'none'."
  }
}

variable "memory" {
  description = "(Optional) Amount (in MiB) of memory used by the task. If the `requires_compatibilities` is `FARGATE` this field is required"
  type        = number
  default     = 2048
}

variable "network_mode" {
  description = "(Optional) Docker networking mode to use for the containers in the task. Valid values are `none`, `bridge`, `awsvpc`, and `host`"
  type        = string
  default     = "awsvpc"

  validation {
    condition     = var.network_mode == null || contains(["none", "bridge", "awsvpc", "host"], var.network_mode)
    error_message = "The 'network_mode' must be one of 'none', 'bridge', 'awsvpc', or 'host'."
  }
}

variable "pid_mode" {
  description = "(Optional) Process namespace to use for the containers in the task. The valid values are `host` and `task`"
  type        = string
  default     = null

  validation {
    condition     = var.pid_mode == null || contains(["host", "task"], var.pid_mode)
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
    expression = optional(string)
    type       = string
  }))
  default = []
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
}

variable "volume" {
  description = <<-EOT
    (Optional) Configuration block for volumes that containers in your task may use. Supports the following configurations:
      (Optional) `docker_volume_configuration` - Configuration block to configure a Docker volume.
      (Optional) `efs_volume_configuration` - Configuration block for an EFS volume.
      (Optional) `fsx_windows_file_server_volume_configuration` - Configuration block for an FSX Windows File Server volume.
      (Optional) `host_path` - Path on the host container instance that is presented to the container.
      (Optional) `configure_at_launch` - Whether the volume should be configured at launch time.
      (Required) `name` - Name of the volume.
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
      transit_encryption      = optional(string)
      transit_encryption_port = optional(number)
      authorization_config = optional(object({
        access_point_id = optional(string)
        iam             = optional(string)
      }))
    }))
    fsx_windows_file_server_volume_configuration = optional(object({
      file_system_id = string
      root_directory = string
      authorization_config = object({
        credentials_parameter = string
        domain                = string
      })
    }))
    host_path           = optional(string)
    configure_at_launch = optional(bool)
    name                = string
  }))
  default = {}
}

variable "task_tags" {
  description = "(Optional) A map of additional tags to add to the task definition/set created"
  type        = map(string)
  default     = {}
}

################################################################################
# Task Execution - IAM Role
################################################################################

variable "create_task_exec_iam_role" {
  description = "(Optional) Determines whether the ECS task definition IAM role should be created"
  type        = bool
  default     = true
}

variable "task_exec_iam_role_arn" {
  description = "(Optional) Existing IAM role ARN"
  type        = string
  default     = null
}

variable "task_exec_iam_role_name" {
  description = "(Optional) Name to use on IAM role created"
  type        = string
  default     = null
  nullable    = true
}

variable "task_exec_iam_role_use_name_prefix" {
  description = "(Optional) Determines whether the IAM role name (`task_exec_iam_role_name`) is used as a prefix"
  type        = bool
  default     = true
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
}

variable "task_exec_iam_role_policies" {
  description = "(Optional) Map of IAM role policy ARNs to attach to the IAM role"
  type        = map(string)
  default     = {}
}

variable "task_exec_iam_role_max_session_duration" {
  description = "(Optional) Maximum session duration (in seconds) for ECS task execution role. Default is 3600."
  type        = number
  default     = null
}

variable "create_task_exec_policy" {
  description = "(Optional) Determines whether the ECS task definition IAM policy should be created. This includes permissions included in AmazonECSTaskExecutionRolePolicy as well as access to secrets and SSM parameters"
  type        = bool
  default     = true
}

variable "task_exec_ssm_param_arns" {
  description = "(Optional) List of SSM parameter ARNs the task execution role will be permitted to get/read"
  type        = list(string)
  default     = ["arn:aws:ssm:*:*:parameter/*"]
}

variable "task_exec_secret_arns" {
  description = "(Optional) List of SecretsManager secret ARNs the task execution role will be permitted to get/read"
  type        = list(string)
  default     = ["arn:aws:secretsmanager:*:*:secret:*"]
}

variable "task_exec_iam_statements" {
  description = <<-EOT
    (Optional) A map of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for custom permission usage"
    Note: Same `iam_role_statements` variable configuration applies here.
  EOT
  type = map(object({
    sid           = optional(string)
    actions       = list(string)
    not_actions   = optional(list(string))
    effect        = string
    resources     = list(string)
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
  default = {}
}

variable "task_exec_iam_policy_path" {
  description = "(Optional) Path for the iam role"
  type        = string
  default     = null
}

################################################################################
# Tasks - IAM role
################################################################################

variable "create_tasks_iam_role" {
  description = "(Optional) Determines whether the ECS tasks IAM role should be created"
  type        = bool
  default     = true
}

variable "tasks_iam_role_arn" {
  description = "(Optional) Existing IAM role ARN"
  type        = string
  default     = null
}

variable "tasks_iam_role_name" {
  description = "(Optional) Name to use on IAM role created"
  type        = string
  default     = null
}

variable "tasks_iam_role_use_name_prefix" {
  description = "(Optional) Determines whether the IAM role name (`tasks_iam_role_name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "tasks_iam_role_path" {
  description = "(Optional) IAM role path"
  type        = string
  default     = null
}

variable "tasks_iam_role_description" {
  description = "(Optional) Description of the role"
  type        = string
  default     = null
}

variable "tasks_iam_role_permissions_boundary" {
  description = "(Optional) ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}

variable "tasks_iam_role_tags" {
  description = "(Optional) A map of additional tags to add to the IAM role created"
  type        = map(string)
  default     = {}
}

variable "tasks_iam_role_policies" {
  description = "(Optional) Map of IAM role policy ARNs to attach to the IAM role"
  type        = map(string)
  default     = {}
}

variable "tasks_iam_role_statements" {
  description = <<-EOT
    (Optional) A map of IAM policy statements for custom permission usage. Each statement supports the following:
    Note: Same `iam_role_statements` variable configuration applies here.
  EOT
  type = map(object({
    sid           = optional(string)
    actions       = list(string)
    not_actions   = optional(list(string))
    effect        = string
    resources     = list(string)
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
  default = {}
}
