resource "aws_ecs_service" "this" {
  name                               = format("%s-service", var.cluster_name)
  cluster                            = var.ecs_cluster_id
  task_definition                    = var.task_definition_arn
  desired_count                      = var.desired_count
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent

  placement_constraints {
    type = "distinctInstance"
  }

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.security_group_id]
  }

  capacity_provider_strategy {
    capacity_provider = var.capacity_provider_name
    weight            = 100
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = format("%s-container", var.cluster_name)
    container_port   = var.port_mappings[0].container_port
  }

  deployment_circuit_breaker {
    enable   = var.deployment_circuit_breaker_enable
    rollback = var.deployment_circuit_breaker_rollback
  }

  tags = var.tags
}

/*
resource "aws_ecs_task_definition" "this" {
  family                   = var.task_definition_family
  container_definitions    = jsonencode(var.container_definitions)
  execution_role_arn       = aws_iam_role.this["ecs_task"].arn
  task_role_arn            = aws_iam_role.this["ecs_task"].arn
  network_mode             = var.network_mode
  requires_compatibilities = var.requires_compatibilities
  cpu                      = var.cpu
  memory                   = var.memory
}
*/
