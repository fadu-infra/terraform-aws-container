################################################################################
# Service
################################################################################

variable "name" {
  description = "(Required) Name of the service (up to 255 letters, numbers, hyphens, and underscores)"
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+$", var.name))
    error_message = "The 'name' must contain only letters, numbers, hyphens, and underscores."
  }
}

variable "cluster_name" {
  description = "(Required) Name of the ECS cluster where the resources will be provisioned"
  type        = string
  nullable    = false
}

variable "task_definition_arn" {
  description = "(Required) The ARN of the ECS task definition to use for the service."
  type        = string
  default     = null
  nullable    = true
}

################################################################################
# Deployment Configuration
################################################################################

variable "scheduling_strategy" {
  description = "(Optional) Scheduling strategy to use for the service. The valid values are `REPLICA`."
  type        = string
  default     = "REPLICA"
  nullable    = false

  validation {
    condition     = var.scheduling_strategy == "REPLICA"
    error_message = "The 'scheduling_strategy' must be 'REPLICA'. We don't support 'DAEMON' scheduling strategy."
  }
}

variable "desired_count" {
  description = "(Optional) Number of instances of the task definition to place and keep running"
  type        = number
  default     = 0
  nullable    = false
}

variable "platform_version" {
  description = "(Optional) Platform version on which to run your service. Only applicable for `launch_type` set to `FARGATE`. Defaults to `LATEST`"
  type        = string
  default     = "LATEST"
  nullable    = true
}

variable "enable_availability_zone_rebalancing" {
  description = "(Optional) Whether to enable availability zone rebalancing"
  type        = bool
  default     = false
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
  default     = false
  nullable    = false
}

variable "health_check_grace_period_seconds" {
  description = "(Optional) Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown, up to 2147483647. Only valid for services configured to use load balancers"
  type        = number
  default     = 0
  nullable    = false

  validation {
    condition     = try(var.health_check_grace_period_seconds <= 2147483647, false)
    error_message = "The 'health_check_grace_period_seconds' must not exceed 2147483647."
  }
}

variable "alarms" {
  description = <<-EOT
  (Optional) Information about the CloudWatch alarms. The alarms configuration block supports the following:
    (Required) `names` - One or more CloudWatch alarm names.
    (Required) `enable` - Whether to use the CloudWatch alarm option in the service deployment process.
    (Required) `rollback` - Whether to configure Amazon ECS to roll back the service if a service deployment fails.
  EOT
  type = object({
    names    = list(string)
    enable   = bool
    rollback = bool
  })
  default  = null
  nullable = true
}

variable "volume_configuration" {
  description = <<-EOT
  (Optional) Configuration for a volume specified in the task definition as a volume that is configured at launch time. Currently, the only supported volume type is an Amazon EBS volume.
  This configuration only applies to volumes in the task definition that have `configure_at_launch = true` set.
    (Required) `name` - Name of the volume. Must match the name of a volume in the task definition with `configure_at_launch = true`.
    (Required) `managed_ebs_volume` - Configuration block for the Amazon EBS volume that Amazon ECS creates and manages on your behalf.
      (Required) `role_arn` - Amazon ECS infrastructure IAM role that is used to manage your Amazon Web Services infrastructure.
      (Optional) `encrypted` - Whether the volume should be encrypted. Defaults to true.
      (Optional) `file_system_type` - Linux filesystem type for the volume. Valid values are 'ext3', 'ext4', 'xfs'. Defaults to 'xfs'.
      (Optional) `iops` - Number of I/O operations per second (IOPS).
      (Optional) `kms_key_id` - ARN of the AWS Key Management Service key to use for Amazon EBS encryption.
      (Optional) `size_in_gb` - Size of the volume in GiB. You must specify either a size_in_gb or a snapshot_id.
      (Optional) `snapshot_id` - Snapshot that Amazon ECS uses to create the volume. You must specify either a size_in_gb or a snapshot_id.
      (Optional) `throughput` - Throughput to provision for a volume, in MiB/s, with a maximum of 1,000 MiB/s.
      (Optional) `volume_type` - Volume type.
      (Optional) `tag_specifications` - The tags to apply to the volume.
        (Required) `resource_type` - The type of resource to tag.
        (Optional) `propagate_tags` - Whether to propagate the tags to the resource.
        (Optional) `tags` - A map of tags to add to the resource. 'AmazonECSCreated' and 'AmazonECSManaged' are reserved tags that can't be used.
  EOT
  type = object({
    name = string
    managed_ebs_volume = object({
      role_arn         = string
      encrypted        = optional(bool, true)
      file_system_type = optional(string, "xfs")
      iops             = optional(number)
      kms_key_id       = optional(string)
      size_in_gb       = optional(number)
      snapshot_id      = optional(string)
      throughput       = optional(number)
      volume_type      = optional(string)
      tag_specifications = optional(list(object({
        resource_type  = string
        propagate_tags = optional(bool)
        tags           = optional(map(string))
      })))
    })
  })
  default  = null
  nullable = true
}

variable "capacity_provider_strategies" {
  description = <<-EOT
  (Optional) A list of capacity provider strategies for the ECS service. Each entry in the list should have the following keys:
    (Required) `name` - The short name of the capacity provider.
    (Optional) `base` - The minimum number of tasks to run on the specified capacity provider.
    (Required) `weight` - The relative percentage of the total number of launched tasks that should use the specified capacity provider.
  EOT
  type = list(object({
    name   = string
    base   = optional(number)
    weight = number
  }))

  default  = []
  nullable = false

  validation {
    condition     = alltrue([for strategy in var.capacity_provider_strategies : strategy.weight >= 0 && strategy.weight <= 100])
    error_message = "Each 'weight' must be a number between 0 and 100, inclusive."
  }
}

variable "deployment_options" {
  description = <<-EOT
  (Optional) Deployment settings including:
    (Optional) `controller_type` - Type of deployment controller. Valid values are `ECS`, `CODE_DEPLOY`, and `EXTERNAL`.
    (Optional) `maximum_healthy_percent` - Upper limit (as a percentage of the service's `desired_count`) of the number of running tasks that can be running in a service during a deployment
    (Optional) `minimum_healthy_percent` - Lower limit (as a percentage of the service's `desired_count`) of the number of running tasks that must remain running and healthy in a service during a deployment
  EOT
  type = object({
    controller_type         = optional(string, "ECS")
    maximum_healthy_percent = optional(number, 200)
    minimum_healthy_percent = optional(number, 100)
  })
  default  = {}
  nullable = false

  validation {
    condition     = contains(["ECS", "CODE_DEPLOY", "EXTERNAL"], var.deployment_options.controller_type)
    error_message = "The 'controller_type' must be one of 'ECS', 'CODE_DEPLOY', or 'EXTERNAL'."
  }
}

variable "deployment_circuit_breaker" {
  description = <<-EOT
  (Optional) Deployment circuit breaker for the service.
    (Required) `enable` - Whether to enable the deployment circuit breaker.
    (Required) `rollback` - Whether to configure Amazon ECS to roll back the service if a service deployment fails.
  EOT
  type = object({
    enable   = bool
    rollback = bool
  })
  default  = null
  nullable = true
}

################################################################################
# Networking
################################################################################

variable "network_configuration" {
  description = <<-EOT
  (Optional) Network configuration for the ECS service, including:
    (Required) `subnet_ids` - List of subnets to associate with the task or service.
    (Optional) `security_group_ids` - List of security groups to associate with the task or service.
    (Optional) `assign_public_ip` - Assign a public IP address to the ENI (Fargate launch type only).
  EOT
  type = object({
    subnet_ids         = list(string)
    security_group_ids = optional(list(string))
    assign_public_ip   = optional(bool, false)
  })
  default  = null
  nullable = true
}

################################################################################
# Load Balancers
################################################################################

variable "load_balancers" {
  description = <<-EOT
  (Optional) Configuration block for load balancers. The configuration supports the following:
    (Required) `container_name` - The name of the container to associate with the load balancer.
    (Required) `container_port` - The port on the container to associate with the load balancer.
    (Optional) `elb_name` - The name of the Elastic Load Balancer. Required for ELB Classic to associate with the service.
    (Optional) `target_group_arn` - (Required for ALB/NLB) ARN of the Load Balancer target group to associate with the service.
  EOT
  type = list(object({
    container_name   = string
    container_port   = number
    elb_name         = optional(string)
    target_group_arn = optional(string)
  }))
  default  = []
  nullable = false
}

################################################################################
# Task Placement
################################################################################

variable "ordered_placement_strategy" {
  description = <<-EOT
  (Optional) Service level strategy rules that are taken into consideration during task placement. List from top to bottom in order of precedence. Max 5 strategies.
    (Required) `type` - Type of placement strategy. Must be one of: `binpack`, `random`, or `spread`
    (Optional) `field` - For the `spread` placement strategy, valid values are `instanceId` (or `host`, which has the same effect), or any platform or custom attribute that is applied to a container instance. For the `binpack` type, valid values are `memory` and `cpu`. For the `random` type, this attribute is not needed.
  EOT
  type = list(object({
    type  = string
    field = optional(string)
  }))
  default = [
    {
      type  = "spread"
      field = "attribute:ecs.availability-zone"
    },
    {
      type  = "spread"
      field = "instanceId"
    }
  ]
  nullable = false

  validation {
    condition     = length(var.ordered_placement_strategy) <= 5
    error_message = "A maximum of 5 ordered placement strategies can be specified."
  }

  validation {
    condition = alltrue([
      for strategy in var.ordered_placement_strategy :
      contains(["binpack", "random", "spread"], strategy.type
    )])
    error_message = "Placement strategy type must be one of: binpack, random, or spread."
  }

  validation {
    condition = alltrue([
      for strategy in var.ordered_placement_strategy :
      strategy.type != "binpack" || contains(["memory", "cpu"], strategy.field)
    ])
    error_message = "For binpack placement strategy, field must be either 'memory' or 'cpu'."
  }
}

variable "placement_constraints" {
  description = <<-EOT
  (Optional) Configuration block for rules that are taken into consideration during task placement (up to max of 10). This is set at the service level. Supports the following:
    (Required) `type` - Type of constraint. The only valid values at this time are `memberOf` and `distinctInstance`.
    (Optional) `expression` - Cluster Query Language expression to apply to the constraint. This is not required when the `type` is `distinctInstance`.
  EOT
  type = list(object({
    type       = string
    expression = optional(string)
  }))
  default  = []
  nullable = false

  validation {
    condition     = alltrue([for constraint in var.placement_constraints : contains(["memberOf", "distinctInstance"], constraint.type)])
    error_message = "Each 'type' must be either 'memberOf' or 'distinctInstance'."
  }
}

################################################################################
# Service Connect
################################################################################

variable "service_connect_configuration" {
  description = <<-EOT
  (Optional) The ECS Service Connect configuration for this service.
    (Required) `enabled` - Whether to enable service connect.
    (Optional) `namespace` - The namespace for service connect.
    (Optional) `log_configuration` - Configuration block for logging.
      (Required) `log_driver` - The log driver to use.
      (Optional) `options` - Key-value pairs to configure the log driver.
      (Optional) `secret_option` - List of secret options.
        (Required) `name` - Name of the secret option.
        (Required) `value_from` - Value from the secret option.
    (Optional) `service` - Service configuration block.
      (Required) `port_name` - Name of the port.
      (Optional) `discovery_name` - Service discovery name.
      (Optional) `ingress_port_override` - Override port for ingress.
      (Optional) `client_alias` - Client alias configuration.
        (Required) `port` - Port number for the client alias.
        (Optional) `dns_name` - DNS name for the client alias.
  EOT
  type = object({
    enabled   = bool
    namespace = optional(string)
    log_configuration = optional(object({
      log_driver = string
      options    = optional(map(string))
      secret_option = optional(list(object({
        name       = string
        value_from = string
      })))
    }))
    service = optional(list(object({
      port_name             = string
      discovery_name        = optional(string)
      ingress_port_override = optional(number)
      client_alias = optional(list(object({
        port     = number
        dns_name = optional(string)
      })))
    })))
  })
  default  = null
  nullable = true

  validation {
    condition = var.service_connect_configuration == null || !var.service_connect_configuration.enabled || (
      var.service_connect_configuration.enabled &&
      var.service_connect_configuration.service != null &&
      length(var.service_connect_configuration.service) > 0
    )
    error_message = "When service_connect_configuration.enabled is true, at least one service configuration must be provided."
  }
}

################################################################################
# Service Discovery
################################################################################

variable "service_discovery_registries" {
  description = <<-EOT
  (Optional) Service discovery registries for the service. Supports the following:
    (Required) `registry_arn` - ARN of the Service Registry. The currently supported service registry is Amazon Route 53 Auto Naming Service (aws_service_discovery_service).
    (Optional) `port` - Port value used if your Service Discovery service specified an SRV record.
    (Optional) `container_port` - Port value, already specified in the task definition, to be used for your service discovery service.
    (Optional) `container_name` - Container name value, already specified in the task definition, to be used for your service discovery service.
  EOT
  type = object({
    registry_arn   = string
    port           = optional(number)
    container_name = optional(string)
    container_port = optional(number)
  })
  default  = null
  nullable = true
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
  default  = {}
  nullable = false
}

variable "triggers" {
  description = "(Optional) Map of arbitrary keys and values that, when changed, will trigger an in-place update (redeployment). Useful with plantimestamp()."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "wait_for_steady_state" {
  description = "(Optional) If true, Terraform will wait for the service to reach a steady state (like 'aws ecs wait services-stable') before continuing."
  type        = bool
  default     = false
  nullable    = false
}

variable "tag_specifications" {
  description = <<-EOT
  (Optional) The tag specification configuration for the EBS volumes used in the ECS service.
    (Required) `resource_type` - The type of resource to tag.
    (Optional) `propagate_tags` - Whether to propagate the tags to the resource.
    (Optional) `tags` - A map of tags to add to the resource.
  EOT
  type = list(object({
    resource_type  = string
    propagate_tags = optional(bool)
    tags           = optional(map(string))
  }))
  default  = []
  nullable = false

  validation {
    condition     = length(var.tag_specifications) == 0 || alltrue([for ts in var.tag_specifications : ts.resource_type == "volume"])
    error_message = "The resource_type value must be 'volume'."
  }
}


################################################################################
# Service Auto Scaling
################################################################################

variable "service_autoscaling_enabled" {
  description = "(Optional) Whether to enable service autoscaling"
  type        = bool
  default     = false
  nullable    = false
}

variable "min_capacity" {
  description = "(Optional) The minimum capacity of the ECS service. Required if `service_autoscaling_enabled` is true."
  type        = number
  default     = null
  nullable    = true
}

variable "max_capacity" {
  description = "(Optional) The maximum capacity of the ECS service. Required if `service_autoscaling_enabled` is true."
  type        = number
  default     = null
  nullable    = true
}

variable "scaling_policies" {
  description = <<EOF
  (Optional) A list of ECS service scaling policies.
    (Required) `name` - The name of the scaling policy.
    (Required) `policy_type` - "TargetTrackingScaling", "StepScaling" are supported.

    (Optional) `target_tracking_configuration` - The configuration for target tracking scaling.
      (Required) `target_value` - The target value for the metric.
      (Optional) `disable_scale_in` - Whether to disable scale in.
      (Optional) `scale_in_cooldown` - The cooldown period for scale in.
      (Optional) `scale_out_cooldown` - The cooldown period for scale out.
      (Optional) `predefined_metric_specification` - A predefined metric specification.
        (Required) `predefined_metric_type` - The metric type. One of: "ECSServiceAverageCPUUtilization", "ECSServiceAverageMemoryUtilization", or "ALBRequestCountPerTarget".
        (Optional) `resource_label` - Identifies the resource associated with the metric type (required for ALB metrics).

    (Optional) `step_scaling_configuration` - The configuration for step scaling.
      (Required) `adjustment_type` - The adjustment type. One of: "ChangeInCapacity", "ExactCapacity", or "PercentChangeInCapacity".
      (Optional) `cooldown` - The cooldown period for step scaling.
      (Optional) `metric_aggregation_type` - The aggregation type for the metric. One of: "Average", "Minimum", "Maximum", or "Sum".
      (Optional) `min_adjustment_magnitude` - The minimum adjustment magnitude.
      (Optional) `step_adjustment` - A list of step adjustments.
        (Required) `scaling_adjustment` - The scaling adjustment.
        (Optional) `metric_interval_lower_bound` - The lower bound for the metric interval.
        (Optional) `metric_interval_upper_bound` - The upper bound for the metric interval.
  EOF

  type = list(object({
    name        = string
    policy_type = string

    target_tracking_configuration = optional(object({
      target_value       = number
      disable_scale_in   = optional(bool, false)
      scale_in_cooldown  = optional(number)
      scale_out_cooldown = optional(number)

      predefined_metric_specification = optional(object({
        predefined_metric_type = string
        resource_label         = optional(string)
      }))
    }))

    step_scaling_configuration = optional(object({
      adjustment_type          = string
      cooldown                 = optional(number)
      metric_aggregation_type  = optional(string)
      min_adjustment_magnitude = optional(number)

      step_adjustment = list(object({
        scaling_adjustment          = number
        metric_interval_lower_bound = optional(string)
        metric_interval_upper_bound = optional(string)
      }))
    }))
  }))
  default  = []
  nullable = false
}

variable "scaling_alarms" {
  description = <<EOF
  (Optional) Settings for CloudWatch alarms attached to scaling policies
    (Required) `name` - The name of the alarm.
    (Required) `comparison_operator` - The arithmetic operation to use when comparing the specified statistic and threshold.
    (Required) `evaluation_periods` - The number of periods over which data is compared to the specified threshold.
    (Optional) `metric_name` - The name for the alarm's associated metric.
    (Optional) `namespace` - The namespace for the alarm's associated metric.
    (Optional) `period` - The period in seconds over which the specified statistic is applied.
    (Optional) `statistic` - The statistic to apply to the alarm's associated metric.
    (Optional) `threshold` - The value against which the specified statistic is compared.
    (Optional) `alarm_description` - The description for the alarm.
    (Required) `scaling_policy_name` - The name of the scaling policy to attach to this alarm.
    (Optional) `dimensions` - The dimensions for the alarm's associated metric.
  EOF
  type = list(object({
    name                = string
    comparison_operator = string
    evaluation_periods  = number
    metric_name         = optional(string)
    namespace           = optional(string)
    period              = optional(number)
    statistic           = optional(string)
    threshold           = optional(number)
    alarm_description   = optional(string)
    scaling_policy_name = string
    dimensions          = optional(map(string))
  }))
  default  = []
  nullable = false
}

################################################################################
# Service - IAM Role
################################################################################

variable "iam_role_arn" {
  description = <<-EOT
    (Optional) Existing IAM role ARN. Required if using a load balancer without awsvpc network mode.
    If awsvpc is used in task definition, do not specify. Defaults to the ECS service-linked role if available.
  EOT
  type        = string
  default     = null
  nullable    = true
}

################################################################################
# Tags
################################################################################

variable "tags" {
  description = "(Optional) A map of tags to add to all resources"
  type        = map(string)
  default     = {}
  nullable    = false
}
