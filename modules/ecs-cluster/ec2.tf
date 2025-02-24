# Auto Scaling Group
resource "aws_autoscaling_group" "this" {
  name                  = "${local.name}-asg"
  max_size              = local.asg_max_size
  min_size              = local.asg_min_size
  vpc_zone_identifier   = local.subnet_ids
  protect_from_scale_in = local.protect_from_scale_in
  desired_capacity_type = "units"

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 100
      instance_warmup        = 300
      checkpoint_delay       = 300
      checkpoint_percentages = [50, 100]
    }
  }

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = local.on_demand_base_capacity
      on_demand_percentage_above_base_capacity = local.spot
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.this.id
        version            = aws_launch_template.this.latest_version
      }

      dynamic "override" {
        for_each = local.instance_types

        content {
          instance_type     = override.key
          weighted_capacity = override.value
        }
      }
    }
  }

  dynamic "initial_lifecycle_hook" {
    for_each = local.lifecycle_hooks
    iterator = hook
    content {
      name                    = hook.value.name
      lifecycle_transition    = hook.value.lifecycle_transition
      default_result          = hook.value.default_result
      heartbeat_timeout       = hook.value.heartbeat_timeout
      role_arn                = hook.value.role_arn
      notification_target_arn = hook.value.notification_target_arn
      notification_metadata   = hook.value.notification_metadata
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }

  dynamic "tag" {
    for_each = merge(local.tags, {
      AmazonECSManaged = "true"
    })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

# Launch Template
data "cloudinit_config" "this" {
  gzip          = false
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = <<-EOT
      #!/bin/bash
      echo ECS_CLUSTER="${local.name}" >> /etc/ecs/ecs.config
      echo ECS_LOGLEVEL="debug" >> /etc/ecs/ecs.config
      echo ECS_ENABLE_CONTAINER_METADATA=true >> /etc/ecs/ecs.config
      echo ECS_ENABLE_SPOT_INSTANCE_DRAINING=${tostring(var.spot)} >> /etc/ecs/ecs.config
      echo ECS_AVAILABLE_LOGGING_DRIVERS=["json-file","awslogs"]
    EOT
  }

  dynamic "part" {
    for_each = local.user_data
    content {
      content_type = "text/x-shellscript"
      content      = part.value
    }
  }
}

resource "aws_launch_template" "this" {
  name                   = "${local.name}-lt"
  image_id               = local.ami_id
  instance_type          = keys(local.instance_types)[0]
  user_data              = data.cloudinit_config.this.rendered
  tags                   = local.tags
  update_default_version = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  network_interfaces {
    associate_public_ip_address = local.public
    security_groups             = module.ecs_security_group.id
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.this.name
  }

  monitoring {
    enabled = true
  }

  dynamic "block_device_mappings" {
    for_each = local.ebs_disks
    content {
      device_name = block_device_mappings.key

      ebs {
        delete_on_termination = block_device_mappings.value.delete_on_termination
        volume_size           = block_device_mappings.value.volume_size
        volume_type           = "gp3"
        snapshot_id           = var.use_snapshot ? var.snapshot_id : null
      }
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags          = local.tags
  }

  tag_specifications {
    resource_type = "volume"
    tags          = local.tags
  }
}
