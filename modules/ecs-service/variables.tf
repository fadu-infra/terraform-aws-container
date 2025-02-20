variable "cluster_name" {
  description = "(Required) Cluster name."
  type        = string
}

locals {
  common_name_prefix = "fadu-${var.cluster_name}"
}
