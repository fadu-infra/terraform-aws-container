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
  default  = []
  nullable = false
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

  default  = {}
  nullable = false

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
  nullable    = false
}

variable "enable_ecs_managed_tags" {
  description = "(Optional) Specifies whether to enable Amazon ECS managed tags for the tasks within the service"
  type        = bool
  default     = true
  nullable    = false
}

variable "enable_execute_command" {
  description = "(Optional) Specifies whether to enable Amazon ECS Exec for the tasks within the service"
  type        = bool
  default     = false
  nullable    = false
}

variable "force_new_deployment" {
  description = "(Optional) Enable to force a new task deployment of the service. This can be used to update tasks to use a newer Docker image with same image/tag combination, roll Fargate tasks onto a newer platform version, or immediately deploy `ordered_placement_strategy` and `placement_constraints` updates"
  type        = bool
  default     = true
  nullable    = false
}

variable "health_check_grace_period_seconds" {
  description = "(Optional) Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown, up to 2147483647. Only valid for services configured to use load balancers"
  type        = number
  default     = 0
  nullable    = false

  validation {
    condition     = var.health_check_grace_period_seconds == null || try(var.health_check_grace_period_seconds <= 2147483647, false)
    error_message = "The 'health_check_grace_period_seconds' must not exceed 2147483647."
  }
}

variable "launch_type" {
  description = "(Optional) Launch type on which to run your service. The valid values are `EC2`, `FARGATE`, and `EXTERNAL`. Defaults to `FARGATE`"
  type        = string
  default     = "FARGATE"
  nullable    = false
}

variable "load_balancers" {
  description = <<-EOT
    (Optional) Configuration block for load balancers. The configuration supports the following:
      (Required) `container_name` - The name of the container to associate with the load balancer.
      (Required) `container_port` - The port on the container to associate with the load balancer.
      (Optional) `elb_name` - The name of the Elastic Load Balancer. Required for ELB Classic to associate with the service.
      (Optional) `target_group_arn` - (Required for ALB/NLB) ARN of the Load Balancer target group to associate with the service.
  EOT
  type = map(object({
    container_name   = string
    container_port   = number
    elb_name         = optional(string)
    target_group_arn = optional(string)
  }))
  default  = {}
  nullable = false
}

variable "name" {
  description = "(Required) Name of the service (up to 255 letters, numbers, hyphens, and underscores)"
  type        = string
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
    field = optional(string)
  }))
  default  = {}
  nullable = false

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
  default  = []
  nullable = false

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
  nullable    = false

  validation {
    condition     = contains(["REPLICA", "DAEMON"], var.scheduling_strategy)
    error_message = "The 'scheduling_strategy' must be either 'REPLICA' or 'DAEMON'."
  }
}

variable "service_connect_configuration" {
  description = <<-EOT
    (Optional) The ECS Service Connect configuration for this service.
      (Required) `enabled` - Whether to enable service connect.
      (Optional) `log_configuration` - Configuration block for logging.
        (Required) `log_driver` - The log driver to use.
        (Optional) `options` - Key-value pairs to configure the log driver.
        (Optional) `secret_option` - List of secret options.
          (Required) `name` - Name of the secret option.
          (Required) `value_from` - Value from the secret option.
      (Optional) `namespace` - The namespace for service connect.
      (Optional) `service` - Service configuration block.
        (Optional) `client_alias` - Client alias configuration.
          (Optional) `dns_name` - DNS name for the client alias.
          (Required) `port` - Port number for the client alias.
        (Optional) `discovery_name` - Service discovery name.
        (Optional) `ingress_port_override` - Override port for ingress.
        (Required) `port_name` - Name of the port.
  EOT

  type = object({
    enabled = optional(bool, false)
    log_configuration = optional(object({
      log_driver = string
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

  default  = {}
  nullable = false

  validation {
    condition = (
      length(keys(var.service_connect_configuration)) == 0 || (
        try(
          var.service_connect_configuration.enabled == null ||
          contains([true, false], var.service_connect_configuration.enabled),
          true
        )
      )
    )
    error_message = "The 'enabled' field must be either true or false."
  }

  validation {
    condition = (
      length(keys(var.service_connect_configuration)) == 0 ||
      var.service_connect_configuration.service == null || (
        try(
          var.service_connect_configuration.service.port_name != null,
          false
        )
      )
    )
    error_message = "When service is specified, port_name is required."
  }

  validation {
    condition = (
      length(keys(var.service_connect_configuration)) == 0 ||
      try(var.service_connect_configuration.service, null) == null ||
      try(var.service_connect_configuration.service.client_alias, null) == null || (
        try(
          var.service_connect_configuration.service.client_alias.port != null,
          false
        )
      )
    )
    error_message = "When client_alias is specified, port is required."
  }

  validation {
    condition = (
      length(keys(var.service_connect_configuration)) == 0 ||
      var.service_connect_configuration.log_configuration == null || (
        try(
          var.service_connect_configuration.log_configuration.log_driver != null,
          false
        )
      )
    )
    error_message = "When log_configuration is specified, log_driver is required."
  }
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
  default  = {}
  nullable = false
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
  nullable    = false
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
  nullable    = false
}

################################################################################
# Task Definition
################################################################################

variable "network_mode" {
  description = <<-EOT
    (Optional) Docker networking mode to use for the containers in the task definition.
    This specifies how the network interfaces are configured for the containers.
    Valid values are `none`, `bridge`, `awsvpc`, and `host`.
  EOT
  type        = string
  default     = "awsvpc"
  nullable    = false

  validation {
    condition     = var.network_mode == null || try(contains(["none", "bridge", "awsvpc", "host"], var.network_mode), false)
    error_message = "The 'network_mode' must be one of 'none', 'bridge', 'awsvpc', or 'host'."
  }
}

variable "task_definition_arn" {
  description = "(Required) The ARN of the ECS task definition to use for the service."
  type        = string
  default     = null
  nullable    = true
}

################################################################################
# Service - IAM Role
################################################################################

variable "create_iam_role" {
  description = "(Optional) Determines whether the ECS service IAM role should be created"
  type        = bool
  default     = true
  nullable    = false
}

variable "iam_role_arn" {
  description = <<-EOT
    (Optional) Existing IAM role ARN. Required if using a load balancer without awsvpc network mode.
    If awsvpc is used in task definition, do not specify. Defaults to the ECS service-linked role if available.
  EOT
  type        = string
  default     = null
  nullable    = true
}

variable "iam_role_name" {
  description = "(Optional) Name to use on IAM role created"
  type        = string
  default     = ""
  nullable    = false
}

variable "iam_role_use_name_prefix" {
  description = "(Optional) Determines whether the IAM role name (`iam_role_name`) is used as a prefix"
  type        = bool
  default     = true
  nullable    = false
}

variable "iam_role_path" {
  description = "(Optional) IAM role path"
  type        = string
  default     = null
  nullable    = true
}

variable "iam_role_description" {
  description = "(Optional) Description of the role"
  type        = string
  default     = null
  nullable    = true
}

variable "iam_role_permissions_boundary" {
  description = "(Optional) ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
  nullable    = true
}

variable "iam_role_tags" {
  description = "A map of additional tags to add to the IAM role created"
  type        = map(string)
  default     = {}
  nullable    = false
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
    })), [])
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
