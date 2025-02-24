variable "cluster_name" {
  description = "(Required) Cluster name."
  type        = string
  nullable    = false

  validation {
    condition     = length(var.cluster_name) > 0
    error_message = "Cluster name must not be empty."
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

variable "vpc_id" {
  description = "(Required) The VPC ID."
  type        = string
  nullable    = false

  validation {
    condition     = length(var.vpc_id) > 0
    error_message = "VPC ID must not be empty."
  }
}

variable "arm64" {
  description = "(Optional) ECS node architecture. Default is `amd64`. You can change it to `arm64` by activating this flag. If you do, then you should use corresponding instance types."
  type        = bool
  default     = false
  nullable    = true
}

variable "asg_max_size" {
  description = "(Optional)The maximum size the auto scaling group (measured in EC2 instances)."
  type        = number
  default     = 10
  nullable    = false

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

variable "enabled_default_capacity_provider" {
  description = "(Optional) Enable default capacity provider strategy."
  type        = bool
  default     = true
  nullable    = false
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

variable "nodes_with_public_ip" {
  description = "(Optional) Assign public IP addresses to ECS cluster nodes. Useful when an ECS cluster hosted in internet facing networks."
  type        = bool
  default     = false
  nullable    = false
}

variable "on_demand_base_capacity" {
  description = "(Optional) The minimum number of on-demand EC2 instances."
  type        = number
  default     = 0
  nullable    = false

  validation {
    condition     = var.on_demand_base_capacity >= 0
    error_message = "The on_demand_base_capacity value must be a non-negative number."
  }
}

variable "protect_from_scale_in" {
  description = "(Optional) The autoscaling group will not select instances with this setting for termination during scale in events."
  type        = bool
  default     = true
  nullable    = false
}

variable "security_group_ids" {
  description = "(Optional) Additional security group IDs. Default security group would be merged with the provided list."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "spot" {
  description = "(Optional) Choose should we use spot instances or on-demand to populate ECS cluster."
  type        = bool
  default     = false
  nullable    = false
}

variable "tags" {
  description = "(Optional) A map of tags to add to all resources."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "target_capacity" {
  description = "(Optional) The target utilization for the cluster. A number between 1 and 100."
  type        = number
  default     = 100
  nullable    = false
  validation {
    condition     = var.target_capacity >= 1 && var.target_capacity <= 100
    error_message = "Target capacity must be between 1 and 100."
  }
}

variable "trusted_cidr_blocks" {
  description = "(Optional) List of trusted subnets CIDRs with hosts that should connect to the cluster. E.g., subnets with ALB and bastion hosts."
  type        = list(string)
  default     = ["0.0.0.0/0"]
  nullable    = false
}

variable "user_data" {
  description = "(Optional) A shell script will be executed at once at EC2 instance start."
  type        = string
  default     = ""
  nullable    = false
}

variable "common_name_prefix" {
  description = "The common name prefix for the Cluster"
  type        = string
  nullable    = false
}

data "aws_ssm_parameter" "ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

data "aws_ssm_parameter" "ecs_ami_arm64" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/arm64/recommended/image_id"
}

locals {
  ami_id                  = var.arm64 ? data.aws_ssm_parameter.ecs_ami_arm64.value : data.aws_ssm_parameter.ecs_ami.value
  asg_max_size            = var.asg_max_size
  asg_min_size            = var.asg_min_size
  ebs_disks               = var.ebs_disks
  instance_types          = var.instance_types
  lifecycle_hooks         = var.lifecycle_hooks
  name                    = replace(var.cluster_name, " ", "_")
  on_demand_base_capacity = var.on_demand_base_capacity
  protect_from_scale_in   = var.protect_from_scale_in
  public                  = var.nodes_with_public_ip
  spot                    = var.spot == true ? 0 : 100
  target_capacity         = var.target_capacity
  trusted_cidr_blocks     = var.trusted_cidr_blocks
  user_data               = var.user_data == "" ? [] : [var.user_data]
  vpc_id                  = var.vpc_id
  subnet_ids              = var.subnet_ids

  common_name_prefix = var.common_name_prefix
  tags               = var.tags
}
