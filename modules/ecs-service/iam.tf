locals {
  ecs_service_role_name = "${var.name}-EcsServiceRole"
  ecs_service_policies = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole",
  ]
}
################################################################################
# ECS Service Role
################################################################################

resource "aws_iam_role" "ecs_service" {
  name = local.ecs_service_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs.amazonaws.com"
      }
    }]
  })

  tags = merge(
    {
      "Name" = local.metadata.name
    },
    var.tags,
    local.module_tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "ecs_service" {
  count = length(local.ecs_service_policies)

  role       = aws_iam_role.ecs_service.name
  policy_arn = local.ecs_service_policies[count.index]
}
