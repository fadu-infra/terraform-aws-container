variable "create" {
  description = "Determines whether resources will be created (affects all resources)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

################################################################################
# Cluster
################################################################################

variable "cluster_name" {
  description = "Name of the cluster (up to 255 letters, numbers, hyphens, and underscores)"
  type        = string
  default     = ""
}

variable "cluster_configuration" {
  description = "The execute command configuration for the cluster"
  type        = any
  default     = {}
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
}

variable "cluster_service_connect_defaults" {
  description = "Configures a default Service Connect namespace"
  type        = map(string)
  default     = {}
}

################################################################################
# CloudWatch Log Group
################################################################################

variable "create_cloudwatch_log_group" {
  description = "Determines whether a log group is created by this module for the cluster logs. If not, AWS will automatically create one if logging is enabled"
  type        = bool
  default     = true
}

variable "cloudwatch_log_group_name" {
  description = "Custom name of CloudWatch Log Group for ECS cluster"
  type        = string
  default     = null
}

variable "cloudwatch_log_group_retention_in_days" {
  description = "Number of days to retain log events"
  type        = number
  default     = 90
}

variable "cloudwatch_log_group_kms_key_id" {
  description = "If a KMS Key ARN is set, this key will be used to encrypt the corresponding log group. Please be sure that the KMS Key has an appropriate key policy (https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html)"
  type        = string
  default     = null
}

variable "cloudwatch_log_group_tags" {
  description = "A map of additional tags to add to the log group created"
  type        = map(string)
  default     = {}
}

################################################################################
# Capacity Providers
################################################################################

variable "default_capacity_provider_use_fargate" {
  description = "Determines whether to use Fargate or autoscaling for default capacity provider strategy"
  type        = bool
  default     = true
}

variable "fargate_capacity_providers" {
  description = "Map of Fargate capacity provider definitions to use for the cluster"
  type        = any
  default     = {}
}

variable "autoscaling_capacity_providers" {
  description = "Map of autoscaling capacity provider definitions to create for the cluster"
  type        = any
  default     = {}
}

################################################################################
# Task Execution - IAM Role
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html
################################################################################

variable "create_task_exec_iam_role" {
  description = "Determines whether the ECS task definition IAM role should be created"
  type        = bool
  default     = false
}

variable "task_exec_iam_role_name" {
  description = "Name to use on IAM role created"
  type        = string
  default     = null
}

variable "task_exec_iam_role_use_name_prefix" {
  description = "Determines whether the IAM role name (`task_exec_iam_role_name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "task_exec_iam_role_path" {
  description = "IAM role path"
  type        = string
  default     = null
}

variable "task_exec_iam_role_description" {
  description = "Description of the role"
  type        = string
  default     = null
}

variable "task_exec_iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}

variable "task_exec_iam_role_tags" {
  description = "A map of additional tags to add to the IAM role created"
  type        = map(string)
  default     = {}
}

variable "task_exec_iam_role_policies" {
  description = "Map of IAM role policy ARNs to attach to the IAM role"
  type        = map(string)
  default     = {}
}

variable "create_task_exec_policy" {
  description = "Determines whether the ECS task definition IAM policy should be created. This includes permissions included in AmazonECSTaskExecutionRolePolicy as well as access to secrets and SSM parameters"
  type        = bool
  default     = true
}

variable "task_exec_ssm_param_arns" {
  description = "List of SSM parameter ARNs the task execution role will be permitted to get/read"
  type        = list(string)
  default     = ["arn:aws:ssm:*:*:parameter/*"]
}

variable "task_exec_secret_arns" {
  description = "List of SecretsManager secret ARNs the task execution role will be permitted to get/read"
  type        = list(string)
  default     = ["arn:aws:secretsmanager:*:*:secret:*"]
}

variable "task_exec_iam_statements" {
  description = "A map of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for custom permission usage"
  type        = any
  default     = {}
}

################################################################################
# Auto Scaling Group
################################################################################

variable "asg_max_size" {
  description = "(Optional)The maximum size the auto scaling group (measured in EC2 instances)."
  type        = number
  default     = 10

  validation {
    condition     = var.asg_max_size >= 0
    error_message = "ASG max size must be a non-negative number."
  }
}

variable "asg_min_size" {
  description = "(Optional) The minimum size the auto scaling group (measured in EC2 instances)."
  type        = number
  default     = 0
  nullable    = false

  validation {
    condition     = var.asg_min_size >= 0
    error_message = "ASG min size must be a non-negative number."
  }
}

variable "user_data" {
  description = "(Optional) A shell script will be executed at once at EC2 instance start."
  type        = list(string)
  default     = []
}

variable "spot" {
  description = "(Optional) Choose should we use spot instances or on-demand to populate ECS cluster."
  type        = bool
  default     = false
}

variable "protect_from_scale_in" {
  description = "(Optional) The autoscaling group will not select instances with this setting for termination during scale in events."
  type        = bool
  default     = true
}

variable "on_demand_base_capacity" {
  description = "(Optional) The minimum number of on-demand EC2 instances."
  type        = number
  default     = 0

  validation {
    condition     = var.on_demand_base_capacity >= 0
    error_message = "The on_demand_base_capacity value must be a non-negative number."
  }
}

variable "subnet_ids" {
  description = "(Required) A list of subnet IDs."
  type        = list(string)
  nullable    = false

  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "At least one subnet ID must be provided."
  }
}

variable "lifecycle_hooks" {
  description = <<EOF
  (Optional) A list of lifecycle hook actions. See details at https://docs.aws.amazon.com/autoscaling/ec2/userguide/lifecycle-hooks.html.
    (Required) `name` - The name of the lifecycle hook.
    (Required) `lifecycle_transition` - The lifecycle transition.
    (Optional) `default_result` - The default result of the lifecycle hook.
    (Optional) `heartbeat_timeout` - The heartbeat timeout.
    (Optional) `role_arn` - The ARN of the IAM role.
    (Optional) `notification_target_arn` - The ARN of the notification target.
    (Optional) `notification_metadata` - The metadata of the notification.
  EOF
  type = list(object({
    name                    = string
    lifecycle_transition    = string
    default_result          = optional(string)
    heartbeat_timeout       = optional(number)
    role_arn                = optional(string)
    notification_target_arn = optional(string)
    notification_metadata   = optional(string)
  }))
  default  = []
  nullable = false

  validation {
    condition = alltrue([
      for hook in var.lifecycle_hooks :
      length(hook.name) > 0 &&
      contains([
        "autoscaling:EC2_INSTANCE_LAUNCHING",
        "autoscaling:EC2_INSTANCE_TERMINATING"
      ], hook.lifecycle_transition)
    ])
    error_message = "Each lifecycle hook must have a non-empty name and lifecycle_transition must be either 'autoscaling:EC2_INSTANCE_LAUNCHING' or 'autoscaling:EC2_INSTANCE_TERMINATING'."
  }
}

variable "instance_types" {
  description = "(Optional) ECS node instance types. Maps of pairs like `type = weight`. Where weight gives the instance type a proportional weight to other instance types."
  type        = map(number)
  default = {
    "t3a.small" = 2
  }
  nullable = false

  validation {
    condition     = alltrue([for weight in values(var.instance_types) : weight > 0])
    error_message = "All instance type weights must be positive numbers."
  }
}

variable "security_group_ids" {
  description = "(Optional) Additional security group IDs. Default security group would be merged with the provided list."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "ebs_disks" {
  description = <<EOF
  (Optional) A list of additional EBS disks.
    (Optional) `volume_size` - The size of the EBS disk in GB. Range: 1-16384
    (Optional) `delete_on_termination` - Whether the volume should be destroyed on instance termination
  EOF
  type = map(object({
    volume_size           = optional(number)
    delete_on_termination = optional(bool)
  }))
  default  = {}
  nullable = false

  validation {
    condition     = alltrue([for disk in var.ebs_disks : disk.volume_size == null || (disk.volume_size >= 1 && disk.volume_size <= 16384)])
    error_message = "EBS volume size must be between 1 GB and 16384 GB."
  }
}

variable "use_snapshot" {
  description = "(Optional) Use snapshot to create ECS nodes."
  type        = bool
  default     = false
  nullable    = false
}

variable "snapshot_id" {
  description = "(Optional) The snapshot ID to use to create ECS nodes."
  type        = string
  default     = ""
  nullable    = false
}

variable "public" {
  description = "Boolean to determine if the instances should have a public IP address"
  type        = bool
  default     = false
}

variable "ami_id" {
  description = "(Optional) The AMI ID to use for ECS nodes. If not provided, a default AMI will be used based on the architecture."
  type        = string
  default     = ""
  nullable    = false
}
