resource "aws_ecs_cluster" "default" {
  name = local.name
  tags = local.tags
}

resource "aws_ecs_capacity_provider" "asg" {
  name = aws_autoscaling_group.ecs_nodes.name

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_nodes.arn
    managed_termination_protection = local.protect_from_scale_in ? "ENABLED" : "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = 10
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = local.target_capacity
    }
  }
}
