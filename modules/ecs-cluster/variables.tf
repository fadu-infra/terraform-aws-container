variable "create" {
  description = "Determines whether resources will be created (affects all resources)"
  type        = bool
  default     = true
  nullable    = false
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
  nullable    = false
}

################################################################################
# Cluster
################################################################################

variable "name" {
  description = "Name of the cluster (up to 255 letters, numbers, hyphens, and underscores)"
  type        = string
  default     = ""
  nullable    = false
}

variable "cluster_configuration" {
  description = "The execute command configuration for the cluster"
  type        = any
  default     = {}
  nullable    = false
}

variable "cluster_settings" {
  description = "List of configuration block(s) with cluster settings. For example, this can be used to enable CloudWatch Container Insights for a cluster"
  type        = any
  default = [
    {
      name  = "containerInsights"
      value = "enabled"
    }
  ]
  nullable = false
}

variable "cluster_service_connect_defaults" {
  description = "Configures a default Service Connect namespace"
  type        = map(string)
  default     = {}
  nullable    = false
}

################################################################################
# CloudWatch Log Group
################################################################################

variable "create_cloudwatch_log_group" {
  description = "Determines whether a log group is created by this module for the cluster logs. If not, AWS will automatically create one if logging is enabled"
  type        = bool
  default     = true
  nullable    = false
}

variable "cloudwatch_log_group_name" {
  description = "Custom name of CloudWatch Log Group for ECS cluster"
  type        = string
  default     = null
  nullable    = true
}

variable "cloudwatch_log_group_retention_in_days" {
  description = "Number of days to retain log events"
  type        = number
  default     = 90
  nullable    = false
}

variable "cloudwatch_log_group_kms_key_id" {
  description = "If a KMS Key ARN is set, this key will be used to encrypt the corresponding log group. Please be sure that the KMS Key has an appropriate key policy (https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html)"
  type        = string
  default     = null
  nullable    = true
}

variable "cloudwatch_log_group_tags" {
  description = "A map of additional tags to add to the log group created"
  type        = map(string)
  default     = {}
  nullable    = false
}

################################################################################
# Capacity Providers
################################################################################

variable "default_capacity_provider_use_fargate" {
  description = "Determines whether to use Fargate or autoscaling for default capacity provider strategy"
  type        = bool
  default     = true
  nullable    = false
}

variable "fargate_capacity_providers" {
  description = "Map of Fargate capacity provider definitions to use for the cluster"
  type        = any
  default     = {}
  nullable    = false
}

variable "autoscaling_capacity_providers" {
  description = "Map of autoscaling capacity provider definitions to create for the cluster"
  type        = any
  default     = {}
  nullable    = false
}

################################################################################
# Task Execution - IAM Role
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html
################################################################################

variable "create_task_exec_iam_role" {
  description = "Determines whether the ECS task definition IAM role should be created"
  type        = bool
  default     = false
  nullable    = false
}

variable "task_exec_iam_role_name" {
  description = "Name to use on IAM role created"
  type        = string
  default     = null
  nullable    = true
}

variable "task_exec_iam_role_use_name_prefix" {
  description = "Determines whether the IAM role name (`task_exec_iam_role_name`) is used as a prefix"
  type        = bool
  default     = true
  nullable    = false
}

variable "task_exec_iam_role_path" {
  description = "IAM role path"
  type        = string
  default     = null
  nullable    = true
}

variable "task_exec_iam_role_description" {
  description = "Description of the role"
  type        = string
  default     = null
  nullable    = true
}

variable "task_exec_iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
  nullable    = true
}

variable "task_exec_iam_role_tags" {
  description = "A map of additional tags to add to the IAM role created"
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "task_exec_iam_role_policies" {
  description = "Map of IAM role policy ARNs to attach to the IAM role"
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "create_task_exec_policy" {
  description = "Determines whether the ECS task definition IAM policy should be created. This includes permissions included in AmazonECSTaskExecutionRolePolicy as well as access to secrets and SSM parameters"
  type        = bool
  default     = true
  nullable    = false
}

variable "task_exec_ssm_param_arns" {
  description = "List of SSM parameter ARNs the task execution role will be permitted to get/read"
  type        = list(string)
  default     = ["arn:aws:ssm:*:*:parameter/*"]
  nullable    = false
}

variable "task_exec_secret_arns" {
  description = "List of SecretsManager secret ARNs the task execution role will be permitted to get/read"
  type        = list(string)
  default     = ["arn:aws:secretsmanager:*:*:secret:*"]
  nullable    = false
}

variable "task_exec_iam_statements" {
  description = "A map of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for custom permission usage"
  type        = any
  default     = {}
  nullable    = false
}

################################################################################
# Auto Scaling Group
################################################################################

variable "asg_settings" {
  description = <<-EOT
    Settings for the Auto Scaling Group:
    - `max_size`: (Required) The maximum size of the Auto Scaling Group.
    - `min_size`: (Required) The minimum size of the Auto Scaling Group.
    - `desired_capacity_type`: (Required) The type of desired capacity, e.g., "units".
    - `protect_from_scale_in`: (Required) Whether to protect instances from scale-in.
    - `min_healthy_percentage`: (Required) The minimum healthy percentage of instances.
    - `instance_warmup`: (Required) The time, in seconds, that instances need to warm up.
    - `checkpoint_delay`: (Required) The delay, in seconds, for checkpointing.
    - `instance_types`: (Required) A map of instance types and their weights.
    - `lifecycle_hooks`: (Optional) A list of lifecycle hooks with configurations.
    - `on_demand_base_capacity`: (Required) The base capacity for on-demand instances.
    - `spot`: (Required) Whether to use spot instances.
    - `subnet_ids`: (Required) A list of subnet IDs for the Auto Scaling Group.
    - `security_group_ids`: (Required) A list of security group IDs.
    - `ebs_disks`: (Optional) A map of EBS disk configurations.
    - `use_snapshot`: (Required) Whether to use a snapshot for the instances.
    - `snapshot_id`: (Optional) The ID of the snapshot to use.
    - `public`: (Required) Whether the instances should have public IPs.
    - `ami_id`: (Optional) The ID of the AMI to use for the instances.
    - `user_data`: (Optional) A list of shell scripts to be executed at EC2 instance start.
  EOT
  type = object({
    max_size               = number
    min_size               = number
    desired_capacity_type  = string
    protect_from_scale_in  = bool
    min_healthy_percentage = number
    instance_warmup        = number
    checkpoint_delay       = number
    instance_types         = map(number)
    lifecycle_hooks = list(object({
      name                    = string
      lifecycle_transition    = string
      default_result          = optional(string)
      heartbeat_timeout       = optional(number)
      role_arn                = optional(string)
      notification_target_arn = optional(string)
      notification_metadata   = optional(string)
    }))
    tags                    = map(string)
    on_demand_base_capacity = number
    spot                    = bool
    subnet_ids              = list(string)
    security_group_ids      = list(string)
    ebs_disks = map(object({
      volume_size           = optional(number)
      delete_on_termination = optional(bool)
    }))
    use_snapshot = bool
    snapshot_id  = string
    public       = bool
    ami_id       = string
    user_data    = optional(list(string))
  })
  default = {
    max_size                = 10
    min_size                = 0
    desired_capacity_type   = "units"
    protect_from_scale_in   = true
    min_healthy_percentage  = 100
    instance_warmup         = 300
    checkpoint_delay        = 300
    instance_types          = { "t3a.small" = 2 }
    lifecycle_hooks         = []
    tags                    = {}
    on_demand_base_capacity = 0
    spot                    = false
    subnet_ids              = []
    security_group_ids      = []
    ebs_disks               = {}
    use_snapshot            = false
    snapshot_id             = ""
    public                  = false
    ami_id                  = ""
    user_data               = []
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
  Settings for the Launch Template
    http_endpoint               - HTTP endpoint for metadata options
    http_tokens                 - HTTP tokens for metadata options
    http_put_response_hop_limit - HTTP put response hop limit for metadata options
    instance_metadata_tags      - Instance metadata tags option
    monitoring_enabled          - Enable monitoring for the instance
  EOF
  type        = map(any)
  default = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
    monitoring_enabled          = true
  }
  nullable = false
}

variable "module_tags_enabled" {
  description = "(Optional) Whether to create AWS Resource Tags for the module informations."
  type        = bool
  default     = true
  nullable    = false
}
