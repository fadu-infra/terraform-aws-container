variable "create" {
  description = "(Optional) Determines whether resources will be created (affects all resources)"
  type        = bool
  default     = true
  nullable    = false
}

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
      (Required) `enable` - Whether to use the CloudWatch alarm option in the service deployment process.
      (Required) `rollback` - Whether to configure Amazon ECS to roll back the service if a service deployment fails. If rollback is used, when a service deployment fails, the service is rolled back to the last deployment that completed successfully.
  EOT
  type = map(object({
    alarm_names = list(string)
    enable      = bool
    rollback    = bool
  }))
  default = {}
}

variable "capacity_provider_strategy" {
  description = <<-EOT
    (Optional) A map of capacity provider strategies for the ECS service. Each entry in the map should have the following keys:
      (Required) `capacity_provider` - The short name of the capacity provider.
      (Optional) `base` - The minimum number of tasks to run on the specified capacity provider. Defaults to null.
      (Required) `weight` - The relative percentage of the total number of launched tasks that should use the specified capacity provider. Defaults to null.

    This variable allows you to specify how tasks are distributed across different capacity providers, which can be useful for balancing cost and performance.
  EOT

  type = map(object({
    capacity_provider = string
    base              = optional(number)
    weight            = optional(number)
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
      (Optional) `maximum_percent` - Upper limit (as a percentage of the service's `desired_count`) of the number of running tasks that can be running in a service during a deployment
      (Optional) `minimum_healthy_percent` - Lower limit (as a percentage of the service's `desired_count`) of the number of running tasks that must remain running and healthy in a service during a deployment
  EOT

  type = object({
    circuit_breaker         = optional(any, {})
    maximum_percent         = optional(number, 200)
    minimum_healthy_percent = optional(number, 66)
  })
  nullable = false
  default = {
    circuit_breaker         = {}
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

variable "load_balancer" {
  description = "(Optional) Configuration block for load balancers"
  type        = any
  default     = {}
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
  description = "(Optional) Configuration block for rules that are taken into consideration during task placement (up to max of 10). This is set at the service, see `task_definition_placement_constraints` for setting at the task definition"
  type        = any
  default     = {}
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
  description = "(Optional) The ECS Service Connect configuration for this service to discover and connect to services, and be discovered by, and connected from, other services within a namespace"
  type        = any
  default     = {}
}

variable "service_discovery_registries" {
  description = <<-EOT
    (Optional) Service discovery registries for the service. Supports the following:
      (Required) `registry_arn` - ARN of the Service Registry. The currently supported service registry is Amazon Route 53 Auto Naming Service (aws_service_discovery_service).
      (Optional) `port` - Port value used if your Service Discovery service specified an SRV record.
      (Optional) `container_port` - Port value, already specified in the task definition, to be used for your service discovery service.
    - `container_name`: (Optional) Container name value, already specified in the task definition, to be used for your service discovery service.
  EOT
  type        = any
  default     = {}
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
  description = "(Optional) A map of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for custom permission usage"
  type        = any
  default     = {}
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
  description = "(Optional) A map of valid [container definitions](http://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_ContainerDefinition.html). Please note that you should only provide values that are part of the container definition document"
  type        = any
  default     = {}
}

variable "container_definition_defaults" {
  description = "(Optional) A map of default values for [container definitions](http://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_ContainerDefinition.html) created by `container_definitions`"
  type        = any
  default     = {}
}

variable "cpu" {
  description = "(Optional) Number of cpu units used by the task. If the `requires_compatibilities` is `FARGATE` this field is required"
  type        = number
  default     = 1024
}

variable "ephemeral_storage" {
  description = "(Optional) The amount of ephemeral storage to allocate for the task. This parameter is used to expand the total amount of ephemeral storage available, beyond the default amount, for tasks hosted on AWS Fargate"
  type        = any
  default     = {}
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
  description = "(Optional) A map of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for custom permission usage"
  type        = any
  default     = {}
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
  description = "(Optional) A map of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for custom permission usage"
  type        = any
  default     = {}
}
