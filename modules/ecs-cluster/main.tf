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
