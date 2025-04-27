locals {
  step_scaling_policies = {
    for policy in var.scaling_policies : policy.name => policy
    if policy.policy_type == "StepScaling"
  }

  target_tracking_policies = {
    for policy in var.scaling_policies : policy.name => policy
    if policy.policy_type == "TargetTrackingScaling"
  }

  policy_arns = merge(
    { for k, v in aws_appautoscaling_policy.target_tracking : k => v.arn },
    { for k, v in aws_appautoscaling_policy.step_scaling : k => v.arn }
  )
}

resource "aws_appautoscaling_target" "this" {
  service_namespace  = "ecs"
  resource_id        = "service/${var.cluster_name}/${var.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.min_capacity
  max_capacity       = var.max_capacity
}

resource "aws_appautoscaling_policy" "target_tracking" {
  for_each = local.target_tracking_policies

  name               = each.key
  service_namespace  = "ecs"
  resource_id        = aws_appautoscaling_target.this.resource_id
  scalable_dimension = aws_appautoscaling_target.this.scalable_dimension
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    target_value     = each.value.target_tracking_configuration.target_value
    disable_scale_in = lookup(each.value.target_tracking_configuration, "disable_scale_in", false)

    dynamic "predefined_metric_specification" {
      for_each = each.value.target_tracking_configuration.predefined_metric_specification != null ? [each.value.target_tracking_configuration.predefined_metric_specification] : []
      content {
        predefined_metric_type = predefined_metric_specification.value.predefined_metric_type
        resource_label         = lookup(predefined_metric_specification.value, "resource_label", null)
      }
    }

    dynamic "customized_metric_specification" {
      for_each = try(each.value.target_tracking_configuration.customized_metric_specification != null ? [each.value.target_tracking_configuration.customized_metric_specification] : [], [])
      content {
        # Add custom metric fields as needed
      }
    }
  }
}

resource "aws_appautoscaling_policy" "step_scaling" {
  for_each = local.step_scaling_policies

  name               = each.key
  service_namespace  = "ecs"
  resource_id        = aws_appautoscaling_target.this.resource_id
  scalable_dimension = aws_appautoscaling_target.this.scalable_dimension
  policy_type        = "StepScaling"

  step_scaling_policy_configuration {
    adjustment_type          = each.value.adjustment_type
    metric_aggregation_type  = each.value.metric_aggregation_type
    cooldown                 = each.value.cooldown
    min_adjustment_magnitude = each.value.min_adjustment_magnitude

    dynamic "step_adjustment" {
      for_each = each.value.step_adjustments
      content {
        scaling_adjustment          = step_adjustment.value.scaling_adjustment
        metric_interval_lower_bound = lookup(step_adjustment.value, "metric_interval_lower_bound", null)
        metric_interval_upper_bound = lookup(step_adjustment.value, "metric_interval_upper_bound", null)
      }
    }
  }
}
