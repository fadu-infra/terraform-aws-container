terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.83"
    }
  }
}

variable "ami_id" {
  description = "(Optional) The AMI ID to use for ECS nodes. If not provided, a default AMI will be used based on the architecture."
  type        = string
  default     = ""
  nullable    = false
}
