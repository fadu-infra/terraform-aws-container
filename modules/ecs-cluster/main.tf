resource "aws_ecs_cluster" "this" {
  name = local.name
  tags = local.tags
}

# ECS Cluster Capacity Providers
resource "aws_ecs_capacity_provider" "this" {
  name = aws_autoscaling_group.this.name

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.this.arn
    managed_termination_protection = local.protect_from_scale_in ? "ENABLED" : "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = 10
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = local.target_capacity
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = [aws_ecs_capacity_provider.this.name]

  dynamic "default_capacity_provider_strategy" {
    for_each = var.enabled_default_capacity_provider ? [1] : []
    content {
      base              = 1
      weight            = 100
      capacity_provider = aws_ecs_capacity_provider.this.name
    }
  }
}

module "ecs_security_group" {
  source = "git::git@gitlab.fadutec.dev:infra/devops/terraform-aws-network.git//modules/security-group?ref=feature/INFRAOPS-308"
  # source = "app.terraform.io/fadutec/network/aws//modules/security-group"

  name        = "${local.name}-sg"
  description = "ECS nodes for ${local.name}"
  vpc_id      = local.vpc_id
  tags        = local.tags

  ingress_rules = [
    {
      id         = "ingress_rule"
      protocol   = "-1"
      from_port  = 0
      to_port    = 0
      ipv4_cidrs = local.trusted_cidr_blocks
    }
  ]

  egress_rules = [
    {
      id         = "egress_rule"
      protocol   = "-1"
      from_port  = 0
      to_port    = 0
      ipv4_cidrs = ["0.0.0.0/0"]
    }
  ]
}
