data "cloudinit_config" "config" {
  gzip          = false
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = <<EOT
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

resource "aws_launch_template" "node" {
  name                   = "${local.name}-lt"
  image_id               = local.ami_id
  instance_type          = keys(local.instance_types)[0]
  user_data              = data.cloudinit_config.config.rendered
  tags                   = local.tags
  update_default_version = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"  # IMDSv2를 필수로 설정
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  network_interfaces {
    associate_public_ip_address = local.public
    security_groups             = local.sg_ids
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.profile["ec2_instance"].name 
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
