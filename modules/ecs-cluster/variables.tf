variable "cluster_name" {
  description = "(Required) Cluster name."
  type        = string
}

variable "subnet_ids" {
  description = "(Required) A list of subnet IDs."
  type        = list(string)
}

variable "vpc_id" {
  description = "(Required) The VPC ID."
  type        = string
}

variable "arm64" {
  description = "ECS node architecture. Default is `amd64`. You can change it to `arm64` by activating this flag. If you do, then you should use corresponding instance types."
  type        = bool
  default     = false
}

variable "asg_max_size" {
  description = "The maximum size the auto scaling group (measured in EC2 instances)."
  type        = number
  default     = 10
}

variable "asg_min_size" {
  description = "The minimum size the auto scaling group (measured in EC2 instances)."
  type        = number
  default     = 0
}

variable "ebs_disks" {
  description = "A list of additional EBS disks."
  type = map(object({
    volume_size           = string
    delete_on_termination = bool
  }))
  default = {}
}

variable "use_snapshot" {
  description = "Use snapshot to create ECS nodes."
  type        = bool
  default     = false
}

variable "snapshot_id" {
  description = "The snapshot ID to use to create ECS nodes."
  type        = string
  default     = ""
}

variable "enabled_default_capacity_provider" {
  description = "Enable default capacity provider strategy."
  type        = bool
  default     = true
}

variable "instance_types" {
  description = "ECS node instance types. Maps of pairs like `type = weight`. Where weight gives the instance type a proportional weight to other instance types."
  type        = map(any)
  default = {
    "t3a.small" = 2
  }
}

variable "lifecycle_hooks" {
  description = "A list of lifecycle hook actions. See details at https://docs.aws.amazon.com/autoscaling/ec2/userguide/lifecycle-hooks.html."
  type = list(object({
    name                    = string
    lifecycle_transition    = string
    default_result          = string
    heartbeat_timeout       = number
    role_arn                = string
    notification_target_arn = string
    notification_metadata   = string
  }))
  default = []
}

variable "nodes_with_public_ip" {
  description = "Assign public IP addresses to ECS cluster nodes. Useful when an ECS cluster hosted in internet facing networks."
  type        = bool
  default     = false
}

variable "on_demand_base_capacity" {
  description = "The minimum number of on-demand EC2 instances."
  type        = number
  default     = 0
}

variable "protect_from_scale_in" {
  description = "The autoscaling group will not select instances with this setting for termination during scale in events."
  type        = bool
  default     = true
}

variable "security_group_ids" {
  description = "Additional security group IDs. Default security group would be merged with the provided list."
  type        = list(string)
  default     = []
}

variable "spot" {
  description = "Choose should we use spot instances or on-demand to populate ECS cluster."
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}

variable "target_capacity" {
  description = "The target utilization for the cluster. A number between 1 and 100."
  type        = number
  default     = 100
}

variable "trusted_cidr_blocks" {
  description = "List of trusted subnets CIDRs with hosts that should connect to the cluster. E.g., subnets with ALB and bastion hosts."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "user_data" {
  description = "A shell script will be executed at once at EC2 instance start."
  type        = string
  default     = ""
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
  sg_ids                  = distinct(concat(var.security_group_ids, [aws_security_group.ecs_nodes.id]))
  public                  = var.nodes_with_public_ip
  spot                    = var.spot == true ? 0 : 100
  target_capacity         = var.target_capacity
  trusted_cidr_blocks     = var.trusted_cidr_blocks
  user_data               = var.user_data == "" ? [] : [var.user_data]
  vpc_id                  = var.vpc_id
  subnet_ids              = var.subnet_ids

  common_name_prefix = "fadu-${var.cluster_name}"
  tags               = var.tags
}
