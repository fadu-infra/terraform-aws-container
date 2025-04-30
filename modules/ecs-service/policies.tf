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
  count = var.service_autoscaling_enabled ? 1 : 0

  service_namespace  = "ecs"
  resource_id        = "service/${data.aws_ecs_cluster.this.cluster_name}/${var.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.min_capacity
  max_capacity       = var.max_capacity

  lifecycle {
    precondition {
      condition     = var.min_capacity != null || var.max_capacity != null
      error_message = "min_capacity or max_capacity must be set when service_autoscaling_enabled is true"
    }
  }

  tags = var.tags
}

resource "aws_appautoscaling_policy" "target_tracking" {
  for_each = var.service_autoscaling_enabled ? local.target_tracking_policies : {}

  name               = each.key
  policy_type        = "TargetTrackingScaling"
  service_namespace  = aws_appautoscaling_target.this[0].service_namespace
  resource_id        = aws_appautoscaling_target.this[0].resource_id
  scalable_dimension = aws_appautoscaling_target.this[0].scalable_dimension

  target_tracking_scaling_policy_configuration {
    target_value       = each.value.target_tracking_configuration.target_value
    disable_scale_in   = each.value.target_tracking_configuration.disable_scale_in
    scale_in_cooldown  = each.value.target_tracking_configuration.scale_in_cooldown
    scale_out_cooldown = each.value.target_tracking_configuration.scale_out_cooldown

    dynamic "predefined_metric_specification" {
      for_each = each.value.target_tracking_configuration.predefined_metric_specification != null ? [each.value.target_tracking_configuration.predefined_metric_specification] : []
      content {
        predefined_metric_type = predefined_metric_specification.value.predefined_metric_type
        resource_label         = predefined_metric_specification.value.resource_label
      }
    }
  }
}

resource "aws_appautoscaling_policy" "step_scaling" {
  for_each = var.service_autoscaling_enabled ? local.step_scaling_policies : {}

  name               = each.key
  policy_type        = "StepScaling"
  service_namespace  = aws_appautoscaling_target.this[0].service_namespace
  resource_id        = aws_appautoscaling_target.this[0].resource_id
  scalable_dimension = aws_appautoscaling_target.this[0].scalable_dimension

  step_scaling_policy_configuration {
    adjustment_type          = each.value.step_scaling_configuration.adjustment_type
    cooldown                 = each.value.step_scaling_configuration.cooldown
    metric_aggregation_type  = each.value.step_scaling_configuration.metric_aggregation_type
    min_adjustment_magnitude = each.value.step_scaling_configuration.min_adjustment_magnitude

    dynamic "step_adjustment" {
      for_each = each.value.step_scaling_configuration.step_adjustment
      content {
        scaling_adjustment          = step_adjustment.value.scaling_adjustment
        metric_interval_lower_bound = step_adjustment.value.metric_interval_lower_bound
        metric_interval_upper_bound = step_adjustment.value.metric_interval_upper_bound
      }
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "this" {
  for_each = var.service_autoscaling_enabled ? { for alarm in var.scaling_alarms : alarm.name => alarm } : {}

  alarm_name          = each.key
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  metric_name         = each.value.metric_name
  namespace           = each.value.namespace
  period              = each.value.period
  statistic           = each.value.statistic
  threshold           = each.value.threshold
  dimensions          = each.value.dimensions

  alarm_description = each.value.alarm_description
  alarm_actions = [
    try(local.policy_arns[each.value.scaling_policy_name], null)
  ]
  tags = var.tags
}
