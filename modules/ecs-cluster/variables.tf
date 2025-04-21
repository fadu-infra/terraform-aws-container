variable "tags" {
  description = "(Optional) A map of tags to add to all resources"
  type        = map(string)
  default     = {}
  nullable    = false
}

################################################################################
# Cluster
################################################################################

variable "name" {
  description = "(Required) Name of the cluster (up to 255 letters, numbers, hyphens, and underscores)"
  type        = string
  nullable    = false
}

variable "default_execute_command_configuration" {
  description = <<-EOT
  (Optional) Default configuration for execute command configuration for the cluster
    (Optional) `kms_key_id` - KMS key ID to encrypt the data between local client and container
    (Optional) `logging` - The log setting to use for redirecting logs. ('NONE', 'DEFAULT', and 'OVERRIDE'. Default is 'DEFAULT')
    (Optional) `log_configuration` - The log configuration for the results of the execute command actions
      (Optional) `cloud_watch_log_group_name` - The name of the CloudWatch log group to send logs to
  EOT
  type = object({
    kms_key_id = optional(string, null)
    logging    = optional(string, "DEFAULT")
    log_configuration = optional(object({
      cloud_watch_log_group_name = optional(string, null)
    }))
  })
  default = {
    kms_key_id = null
    logging    = "OVERRIDE"
    log_configuration = {
      cloud_watch_log_group_name = null
    }
  }
  nullable = false
}

variable "cluster_configuration" {
  description = <<-EOT
  (Optional) Configuration block for execute command configuration for the cluster
    (Optional) `execute_command_configuration` - The details of the execute command configuration
      (Optional) `kms_key_id` - KMS key ID to encrypt the data between local client and container
      (Optional) `logging` - The log setting to use for redirecting logs. ('NONE', 'DEFAULT', and 'OVERRIDE'. Default is 'DEFAULT')
      (Optional) `log_configuration` - The log configuration for the results of the execute command actions
        (Optional) `cloud_watch_encryption_enabled` - Whether encryption for CloudWatch logs is enabled
        (Optional) `cloud_watch_log_group_name` - The name of the CloudWatch log group to send logs to
        (Optional) `s3_bucket_name` - The name of the S3 bucket to send logs to
        (Optional) `s3_bucket_encryption_enabled` - Whether encryption for S3 bucket logs is enabled
        (Optional) `s3_key_prefix` - The S3 bucket prefix for logs
  EOT
  type = list(object({
    execute_command_configuration = optional(object({
      kms_key_id = optional(string, null)
      logging    = optional(string, "DEFAULT")
      log_configuration = optional(object({
        cloud_watch_encryption_enabled = optional(bool, null)
        cloud_watch_log_group_name     = optional(string, null)
        s3_bucket_name                 = optional(string, null)
        s3_bucket_encryption_enabled   = optional(bool, null)
        s3_key_prefix                  = optional(string, null)
      }))
    }))
  }))
  default  = [{}]
  nullable = false

  validation {
    condition = alltrue([
      for config in var.cluster_configuration :
      config.execute_command_configuration == null || (
        config.execute_command_configuration.logging == null ||
        contains(["NONE", "DEFAULT", "OVERRIDE"], config.execute_command_configuration.logging)
      )
    ])
    error_message = "The logging parameter must be one of: NONE, DEFAULT, or OVERRIDE."
  }
}

variable "container_insights_settings" {
  description = <<-EOT
  (Optional) List of configuration block(s) with cluster settings. For example, this can be used to enable CloudWatch Container Insights for a cluster
    (Required) `name` - The name of the setting to change. Available settings are containerInsights
    (Required) `value` - The value to assign to the setting. Available values are enhanced and enabled and disabled
  EOT
  type = list(object({
    name  = string
    value = string
  }))
  default = [
    {
      name  = "containerInsights"
      value = "enabled"
    }
  ]
  nullable = false

  validation {
    condition = alltrue([
      for setting in var.container_insights_settings :
      setting.name == "containerInsights" &&
      contains(["enabled", "disabled", "enhanced"], setting.value)
    ])
    error_message = "Cluster settings only support 'containerInsights' for name and values must be one of: 'enabled', 'disabled', or 'enhanced'."
  }
}

variable "cluster_service_connect_defaults" {
  description = <<EOT
  (Optional) Configures a default Service Connect namespace
    (Required) `namespace` - The namespace to use for Service Connect
  EOT
  type = list(object({
    namespace = string
  }))
  default  = []
  nullable = false
}

################################################################################
# CloudWatch Log Group
################################################################################

variable "cloudwatch_log_group" {
  description = "(Optional) CloudWatch Log Group configuration for the ECS cluster"
  type = object({
    create            = optional(bool, true)
    name              = optional(string, null)
    retention_in_days = optional(number, 90)
    kms_key_id        = optional(string, null)
    tags              = optional(map(string), {})
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
    (Required) `default_capacity_provider_strategy` - Object containing default capacity provider strategy settings:
      (Optional) `base` - The relative percentage of the total number of launched tasks that should use the specified capacity provider. The weight value is taken into consideration after the base count of tasks has been satisfied.
      (Optional) `weight` - The number of tasks, at a minimum, to run on the specified capacity provider. Only one capacity provider in a capacity provider strategy can have a base defined.
  EOT
  type = map(object({
    name = string
    default_capacity_provider_strategy = object({
      base   = optional(number, null)
      weight = optional(number, null)
    })
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
    (Optional) `name` - Name of the capacity provider
    (Optional) `managed_termination_protection` - Managed termination protection setting. Only valid when managed_scaling is configured ('ENABLED' or 'DISABLED')
    (Optional) `managed_draining` - Enables or disables a graceful shutdown of instances without disturbing workloads. ('ENABLED' or 'DISABLED') The default value is ENABLED when a capacity provider is created.
    (Required) `default_capacity_provider_strategy` - Object containing default capacity provider strategy settings:
      (Optional) `base` - The number of tasks, at a minimum, to run on the specified capacity provider
      (Optional) `weight` - The relative percentage of the total number of launched tasks that should use the specified capacity provider
    (Optional) `managed_scaling` - Object containing managed scaling settings:
      (Optional) `instance_warmup_period` - Period of time, in seconds, to wait before considering a newly launched instance ready. default: 300
      (Optional) `maximum_scaling_step_size` - Maximum step adjustment size (1-10000)
      (Optional) `minimum_scaling_step_size` - Minimum step adjustment size (1-10000)
      (Optional) `status` - Status of managed scaling ('ENABLED' or 'DISABLED')
      (Optional) `target_capacity` - Target capacity percentage (1-100)
    Note: When managed termination protection is enabled, managed scaling must also be configured.
  EOT
  type = object({
    name                           = optional(string, "default-capacity-provider")
    managed_termination_protection = optional(string, "DISABLED")
    managed_draining               = optional(string)
    default_capacity_provider_strategy = optional(object({
      base   = optional(number, null)
      weight = optional(number, null)
    }))
    managed_scaling = optional(object({
      instance_warmup_period    = optional(number, null)
      maximum_scaling_step_size = optional(number, null)
      minimum_scaling_step_size = optional(number, null)
      status                    = optional(string, null)
      target_capacity           = optional(number, null)
    }), {})
  })
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      !can(var.autoscaling_capacity_provider.managed_termination_protection) ||
      contains(["ENABLED", "DISABLED"], var.autoscaling_capacity_provider.managed_termination_protection),

      !can(var.autoscaling_capacity_provider.managed_draining) ||
      contains(["ENABLED", "DISABLED"], var.autoscaling_capacity_provider.managed_draining),

      !can(var.autoscaling_capacity_provider.managed_scaling) || alltrue([
        !can(var.autoscaling_capacity_provider.managed_scaling.status) ||
        contains(["ENABLED", "DISABLED"], var.autoscaling_capacity_provider.managed_scaling.status),

        !can(var.autoscaling_capacity_provider.managed_scaling.target_capacity) ||
        (
          var.autoscaling_capacity_provider.managed_scaling.target_capacity >= 1 &&
          var.autoscaling_capacity_provider.managed_scaling.target_capacity <= 100
        ),

        !can(var.autoscaling_capacity_provider.managed_scaling.maximum_scaling_step_size) ||
        (
          var.autoscaling_capacity_provider.managed_scaling.maximum_scaling_step_size >= 1 &&
          var.autoscaling_capacity_provider.managed_scaling.maximum_scaling_step_size <= 10000
        ),

        !can(var.autoscaling_capacity_provider.managed_scaling.minimum_scaling_step_size) ||
        (
          var.autoscaling_capacity_provider.managed_scaling.minimum_scaling_step_size >= 1 &&
          var.autoscaling_capacity_provider.managed_scaling.minimum_scaling_step_size <= 10000
        )
      ])
    ])
    error_message = "Invalid configuration. Check: managed_termination_protection and managed_draining must be 'ENABLED' or 'DISABLED', managed_scaling.status must be 'ENABLED' or 'DISABLED', target_capacity must be between 1 and 100, scaling step sizes must be between 1 and 10000"
  }
}

################################################################################
# Task Execution - IAM Role
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html
################################################################################

variable "create_task_exec_iam_role" {
  description = "(Optional) Determines whether the ECS task definition IAM role should be created"
  type        = bool
  default     = false
  nullable    = false
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
  (Optional)  A list of IAM policy statements for custom permission usage. Each statement should be an object with the following attributes:
    (Optional) `sid` - A unique identifier for the statement.
    (Optional) `actions` - A list of actions that are allowed or denied.
    (Optional) `not_actions` - A list of actions that are explicitly not allowed.
    (Optional) `effect` - The effect of the statement, either "Allow" or "Deny".
    (Optional) `resources` - A list of resources to which the actions apply.
    (Optional) `not_resources` - A list of resources to which the actions do not apply.
    (Optional) `principals` - A list of principals to which the statement applies.
      (Required) `type` - The type of principal, ("Service", "AWS", "Federated", "CanonicalUser", "*")
      (Required) `identifiers` - A list of identifiers for the principal, e.g., "ecs.amazonaws.com".
    (Optional) `not_principals` - A list of principals to which the statement does not apply.
      (Required) `type` - The type of principal, ("Service", "AWS", "Federated", "CanonicalUser", "*")
      (Required) `identifiers` - A list of identifiers for the principal, e.g., "ecs.amazonaws.com".
    (Optional) `conditions` - A list of conditions that must be met for the statement to apply.
      (Required) `test` - Name of the IAM condition operator to evaluate.
      (Required) `values` - A list of values to test against the condition.
      (Required) `variable` - The variable to test against the condition.
  EOT
  type = list(object({
    sid           = optional(string, null)
    actions       = optional(list(string), null)
    not_actions   = optional(list(string), null)
    effect        = optional(string, null)
    resources     = optional(list(string), null)
    not_resources = optional(list(string), null)
    principals = optional(list(object({
      type        = string
      identifiers = list(string)
    })), [])
    not_principals = optional(list(object({
      type        = string
      identifiers = list(string)
    })), [])
    conditions = optional(list(object({
      test     = string
      values   = list(string)
      variable = string
    })), [])
  }))
  default  = []
  nullable = false
}

################################################################################
# Auto Scaling Group
################################################################################

variable "asg_settings" {
  description = <<-EOT
    (Optional) Settings for the Auto Scaling Group. Required if var.autoscaling_capacity_provider is set.
      (Required) `max_size` - The maximum size of the Auto Scaling Group.
      (Required) `min_size` - The minimum size of the Auto Scaling Group.
      (Optional) `desired_capacity_type` - The type of desired capacity, e.g., "units".
      (Optional) `protect_from_scale_in` - Whether to protect instances from scale-in.
      (Optional) `min_healthy_percentage` - The minimum healthy percentage of instances.
      (Optional) `instance_warmup` - The time, in seconds, that instances need to warm up.
      (Optional) `checkpoint_delay` - The delay, in seconds, for checkpointing.
      (Optional) `instance_types` - A map of instance types and their weights.
      (Optional) `lifecycle_hooks` - A list of lifecycle hooks with configurations.
      (Optional) `on_demand_base_capacity` - The base capacity for on-demand instances.
      (Optional) `spot` - Whether to use spot instances.
      (Required) `subnet_ids` - A list of subnet IDs for the Auto Scaling Group.
      (Optional) `security_group_ids` - A list of security group IDs.
      (Optional) `ebs_disks` - A map of EBS disk configurations.
      (Optional) `public` - Whether the instances should have public IPs.
      (Optional) `ami_id` - The ID of the AMI to use for the instances.
      (Optional) `user_data` - A list of shell scripts to be executed at EC2 instance start.
  EOT
  type = object({
    max_size               = number
    min_size               = number
    desired_capacity_type  = optional(string, "units")
    protect_from_scale_in  = optional(bool, false)
    min_healthy_percentage = optional(number, 100)
    instance_warmup        = optional(number, 300)
    checkpoint_delay       = optional(number, 300)
    instance_types         = optional(map(number), { "t3a.small" = 2 })
    lifecycle_hooks = optional(list(object({
      name                    = string
      lifecycle_transition    = string
      default_result          = optional(string)
      heartbeat_timeout       = optional(number)
      role_arn                = optional(string)
      notification_target_arn = optional(string)
      notification_metadata   = optional(string)
    })), [])
    tags                    = optional(map(string), {})
    on_demand_base_capacity = optional(number, 0)
    spot                    = optional(bool, false)
    subnet_ids              = list(string)
    security_group_ids      = optional(list(string), [])
    ebs_disks = optional(map(object({
      volume_size           = optional(number)
      delete_on_termination = optional(bool)
    })), {})
    snapshot_id = optional(string, null)
    public      = optional(bool, false)
    ami_id      = optional(string, "")
    user_data   = optional(list(string), [])
  })
  default = {
    max_size   = 10
    min_size   = 0
    subnet_ids = []
  }
  nullable = false

  validation {
    condition     = length(var.asg_settings.subnet_ids) > 0
    error_message = "At least one subnet ID must be provided."
  }

  validation {
    condition     = alltrue([for weight in values(var.asg_settings.instance_types) : weight > 0])
    error_message = "All instance type weights must be positive numbers."
  }

  validation {
    condition     = alltrue([for disk in var.asg_settings.ebs_disks : disk.volume_size == null || (disk.volume_size >= 1 && disk.volume_size <= 16384)])
    error_message = "EBS volume size must be between 1 GB and 16384 GB."
  }

  validation {
    condition     = var.asg_settings.on_demand_base_capacity >= 0
    error_message = "The on_demand_base_capacity value must be a non-negative number."
  }

  validation {
    condition = alltrue([
      for hook in var.asg_settings.lifecycle_hooks :
      length(hook.name) > 0 &&
      contains([
        "autoscaling:EC2_INSTANCE_LAUNCHING",
        "autoscaling:EC2_INSTANCE_TERMINATING"
      ], hook.lifecycle_transition)
    ])
    error_message = "Each lifecycle hook must have a non-empty name and lifecycle_transition must be either 'autoscaling:EC2_INSTANCE_LAUNCHING' or 'autoscaling:EC2_INSTANCE_TERMINATING'."
  }
}

variable "launch_template_settings" {
  description = <<EOF
  (Optional)Settings for the Launch Template
    (Optional) `http_endpoint` - HTTP endpoint for metadata options
    (Optional) `http_tokens` - HTTP tokens for metadata options
    (Optional) `http_put_response_hop_limit` - HTTP put response hop limit for metadata options
    (Optional) `instance_metadata_tags` - Instance metadata tags option
    (Optional) `monitoring_enabled` - Enable monitoring for the instance
  EOF
  type = object({
    http_endpoint               = optional(string, "enabled")
    http_tokens                 = optional(string, "required")
    http_put_response_hop_limit = optional(number, 1)
    instance_metadata_tags      = optional(string, "enabled")
    monitoring_enabled          = optional(bool, true)
  })
  default  = {}
  nullable = false
}
