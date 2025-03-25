################################################################################
# Auto Scaling Group
################################################################################

locals {
  create_asg = length(var.autoscaling_capacity_provider) > 0 ? 1 : 0
}

resource "aws_autoscaling_group" "this" {
  count = local.create_asg

  name                  = "${var.name}-asg"
  max_size              = var.asg_settings.max_size
  min_size              = var.asg_settings.min_size
  vpc_zone_identifier   = var.asg_settings.subnet_ids
  protect_from_scale_in = var.asg_settings.protect_from_scale_in
  desired_capacity_type = var.asg_settings.desired_capacity_type

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = var.asg_settings.min_healthy_percentage
      instance_warmup        = var.asg_settings.instance_warmup
      checkpoint_delay       = var.asg_settings.checkpoint_delay
      checkpoint_percentages = [50, 100]
    }
  }

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = var.asg_settings.on_demand_base_capacity
      on_demand_percentage_above_base_capacity = var.asg_settings.spot ? 0 : 100
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.this[0].id
        version            = aws_launch_template.this[0].latest_version
      }

      dynamic "override" {
        for_each = var.asg_settings.instance_types

        content {
          instance_type     = override.key
          weighted_capacity = override.value
        }
      }
    }
  }

  dynamic "initial_lifecycle_hook" {
    for_each = var.asg_settings.lifecycle_hooks
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
    for_each = merge(
      {
        "Name" = var.name
      },
      var.tags,
      local.module_tags,
      {
        AmazonECSManaged = "true"
      }
    )
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

################################################################################
# Launch Template
################################################################################

data "cloudinit_config" "this" {
  gzip          = false
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = <<-EOT
      #!/bin/bash
      echo ECS_CLUSTER="${var.name}" >> /etc/ecs/ecs.config
      echo ECS_LOGLEVEL="debug" >> /etc/ecs/ecs.config
      echo ECS_ENABLE_CONTAINER_METADATA=true >> /etc/ecs/ecs.config
      echo ECS_ENABLE_SPOT_INSTANCE_DRAINING=${tostring(var.asg_settings.spot)} >> /etc/ecs/ecs.config
      echo ECS_AVAILABLE_LOGGING_DRIVERS=["json-file","awslogs"]
    EOT
  }

  dynamic "part" {
    for_each = var.asg_settings.user_data
    content {
      content_type = "text/x-shellscript"
      content      = part.value
    }
  }
}

resource "aws_launch_template" "this" {
  count = local.create_asg

  name                   = "${var.name}-lt"
  image_id               = var.asg_settings.ami_id
  instance_type          = keys(var.asg_settings.instance_types)[0]
  user_data              = data.cloudinit_config.this.rendered
  tags                   = var.tags
  update_default_version = true

  metadata_options {
    http_endpoint               = var.launch_template_settings["http_endpoint"]
    http_tokens                 = var.launch_template_settings["http_tokens"]
    http_put_response_hop_limit = var.launch_template_settings["http_put_response_hop_limit"]
    instance_metadata_tags      = var.launch_template_settings["instance_metadata_tags"]
  }

  network_interfaces {
    associate_public_ip_address = var.asg_settings.public
    security_groups             = var.asg_settings.security_group_ids
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance[0].name
  }

  monitoring {
    enabled = var.launch_template_settings["monitoring_enabled"]
  }

  dynamic "block_device_mappings" {
    for_each = var.asg_settings.ebs_disks
    content {
      device_name = block_device_mappings.key

      ebs {
        delete_on_termination = block_device_mappings.value.delete_on_termination
        volume_size           = block_device_mappings.value.volume_size
        volume_type           = "gp3"
        snapshot_id           = var.asg_settings.snapshot_id
      }
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags          = var.tags
  }

  tag_specifications {
    resource_type = "volume"
    tags          = var.tags
  }
}
