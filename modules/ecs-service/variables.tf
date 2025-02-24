variable "ecs_cluster_id" {
  description = "(Optional) The ID of the ECS cluster"
  type        = string
}

variable "security_group_id" {
  description = "(Optional) The ID of the security group"
  type        = string
}

variable "capacity_provider_name" {
  description = "(Required) The name of the capacity provider"
  type        = string
  nullable    = false
}

variable "cluster_name" {
  description = "(Required) Cluster name."
  type        = string
  nullable    = false
}

variable "deployment_circuit_breaker_enable" {
  description = "Enable deployment circuit breaker."
  type        = bool
  default     = false
  nullable    = false
}

variable "deployment_circuit_breaker_rollback" {
  description = "Rollback deployment if circuit breaker is triggered."
  type        = bool
  default     = false
  nullable    = false
}

variable "desired_count" {
  description = "The desired number of instances the task should run on."
  type        = number
  default     = 1
  nullable    = false

  validation {
    condition     = var.desired_count >= 0
    error_message = "The desired_count must be a non-negative number."
  }
}

variable "deployment_minimum_healthy_percent" {
  description = "The minimum healthy percent (between 0 and 100) of the deployment."
  type        = number
  default     = 100
  nullable    = false

  validation {
    condition     = var.deployment_minimum_healthy_percent >= 0 && var.deployment_minimum_healthy_percent <= 100
    error_message = "The deployment_minimum_healthy_percent must be between 0 and 100."
  }
}

variable "deployment_maximum_percent" {
  description = "The maximum percent (between 0 and 200) of the deployment."
  type        = number
  default     = 200
  nullable    = false

  validation {
    condition     = var.deployment_maximum_percent >= 0 && var.deployment_maximum_percent <= 200
    error_message = "The deployment_maximum_percent must be between 0 and 200."
  }
}

variable "subnet_ids" {
  description = "(Required) A list of subnet IDs."
  type        = list(string)
  default     = null
  nullable    = true
}

variable "tags" {
  description = "(Optional) A map of tags to add to all resources."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "common_name_prefix" {
  description = "(Required) The common name prefix for the IAM Policies"
  type        = string
  default     = "default-cluster"
  nullable    = false
}

variable "task_definition_arn" {
  description = "(Required) The ARN of the task definition to use for the ECS service."
  type        = string
  nullable    = false
}

variable "target_group_arn" {
  description = "(Required) The ARN of the target group to associate with the ECS service."
  type        = string
  nullable    = false
}

variable "port_mappings" {
  description = "(Required) A list of port mappings."
  type = list(object({
    container_port = number
    host_port      = number
    protocol       = string
  }))
  default  = []
  nullable = false
}

/*
variable "task_definition_family" {
  description = "The family of the ECS task definition"
  type        = string
  nullable    = false
}

variable "container_definitions" {
  description = "The container definitions as a JSON string"
  type        = string
  nullable    = false
}

variable "network_mode" {
  description = "The network mode for the ECS task"
  type        = string
  default     = "bridge"
  nullable    = false
}

variable "requires_compatibilities" {
  description = "The launch type for the ECS task"
  type        = list(string)
  default     = ["EC2"]
  nullable    = false
}

variable "cpu" {
  description = "The number of CPU units used by the task"
  type        = string
  nullable    = false
}

variable "memory" {
  description = "The amount of memory (in MiB) used by the task"
  type        = string
  nullable    = false
}
*/
