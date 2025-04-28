################################################################################
# Cluster
################################################################################

variable "name" {
  description = "(Required) Name of the cluster (up to 255 letters, numbers, hyphens, and underscores)"
  type        = string
  nullable    = false
}

variable "container_insights_level" {
  description = "(Optional) Whether to enable container insights. Valid values: enhanced, enabled, disabled"
  type        = string
  default     = "enhanced"
  nullable    = false

  validation {
    condition     = contains(["enhanced", "enabled", "disabled"], var.container_insights_level)
    error_message = "The 'container_insights_level' value must be one of 'enhanced', 'enabled', or 'disabled'"
  }
}

variable "kms_key_id" {
  description = "(Optional) The ARN of the KMS key to use for encryption."
  type        = string
  default     = null
  nullable    = true
}

variable "logging" {
  description = "(Optional) The log configuration for the results of the execute command. Valid values: DEFAULT, OVERRIDE, NONE"
  type        = string
  default     = "DEFAULT"
  nullable    = false

  validation {
    condition     = contains(["NONE", "DEFAULT", "OVERRIDE"], var.logging)
    error_message = "The 'logging' value must be one of 'NONE', 'DEFAULT', or 'OVERRIDE'"
  }
}

variable "service_discovery_namespace_arn" {
  description = "(Optional) The ARN of the service discovery namespace to use for service connect."
  type        = string
  default     = null
  nullable    = true
}

variable "log_configuration" {
  description = <<-EOT
  (Optional) The log configuration for the results of the execute command.
    (Optional) `cloud_watch_encryption_enabled` - Whether to enable encryption for the CloudWatch log group.
    (Optional) `cloud_watch_log_group_name` - The name of the CloudWatch log group to use for the results of the execute command.
  EOT
  type = object({
    cloud_watch_encryption_enabled = optional(bool)
    cloud_watch_log_group_name     = optional(string)
  })
  default  = {}
  nullable = false
}

################################################################################
# Capacity Providers
################################################################################

variable "fargate_capacity_providers" {
  description = <<-EOT
  (Optional) Map of Fargate capacity provider definitions to use for the cluster."
    (Required) `name` - Name of the capacity provider. ("FARGATE" or "FARGATE_SPOT")
    (Optional) `default_capacity_provider_strategy` - Object containing default capacity provider strategy settings:
      (Optional) `base` - The relative percentage of the total number of launched tasks that should use the specified capacity provider. The weight value is taken into consideration after the base count of tasks has been satisfied.
      (Optional) `weight` - The number of tasks, at a minimum, to run on the specified capacity provider. Only one capacity provider in a capacity provider strategy can have a base defined.
  EOT
  type = map(object({
    name = string
    default_capacity_provider_strategy = optional(object({
      base   = optional(number, 0)
      weight = optional(number, 0)
    }))
  }))
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      for provider in values(var.fargate_capacity_providers) :
      contains(["FARGATE", "FARGATE_SPOT"], provider.name)
    ])
    error_message = "Fargate capacity provider name must be either 'FARGATE' or 'FARGATE_SPOT'."
  }
}

variable "autoscaling_capacity_provider" {
  description = <<-EOT
   (Optional) Autoscaling capacity provider definition with the following settings:
    (Required) `name` - Name of the capacity provider.
    (Required) `autoscaling_group_arn` - ARN of the Auto Scaling Group
    (Optional) `managed_draining` - Enables or disables a graceful shutdown of instances without disturbing workloads. ('ENABLED' or 'DISABLED') The default value is ENABLED when a capacity provider is created.
    (Optional) `managed_termination_protection` - Managed termination protection setting. Only valid when managed_scaling is configured ('ENABLED' or 'DISABLED')
    (Optional) `managed_scaling` - Object containing managed scaling settings:
        (Optional) `instance_warmup_period` - Period of time, in seconds, to wait before considering a newly launched instance ready. default: 300
        (Optional) `maximum_scaling_step_size` - Maximum step adjustment size (1-10000)
        (Optional) `minimum_scaling_step_size` - Minimum step adjustment size (1-10000)
        (Optional) `status` - Status of managed scaling ('ENABLED' or 'DISABLED')
        (Optional) `target_capacity` - Target capacity percentage (1-100)
    (Optional) `default_capacity_provider_strategy` - Object containing default capacity provider strategy settings:
      (Optional) `base` - The relative percentage of the total number of launched tasks that should use the specified capacity provider. The weight value is taken into consideration after the base count of tasks has been satisfied.
      (Optional) `weight` - The number of tasks, at a minimum, to run on the specified capacity provider. Only one capacity provider in a capacity provider strategy can have a base defined.
    Note: When managed termination protection is enabled, managed scaling must also be configured.
  EOT
  type = map(object({
    name                           = string
    autoscaling_group_arn          = string
    managed_draining               = optional(bool, true)
    managed_termination_protection = optional(bool, false)
    managed_scaling = optional(object({
      enabled                   = optional(bool)
      instance_warmup_period    = optional(number)
      maximum_scaling_step_size = optional(number)
      minimum_scaling_step_size = optional(number)
      target_capacity           = optional(number)
    }))
    default_capacity_provider_strategy = optional(object({
      base   = optional(number, 0)
      weight = optional(number, 0)
    }))
  }))
  default  = {}
  nullable = false
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
