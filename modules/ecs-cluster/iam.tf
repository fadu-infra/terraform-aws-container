# Common IAM policy definitions
locals {
  # ECS Instance Role & Policies
  ecs_instance_role_name = "${local.common_name_prefix}-Ec2InstanceRole"
  ecs_instance_policies = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  ]
}

# ECS Instance Role
resource "aws_iam_role" "ecs_instance" {
  name        = local.ecs_instance_role_name
  description = "Allows EC2 instances to call AWS services on your behalf"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "ecs_instance" {
  count = length(local.ecs_instance_policies)

  role       = aws_iam_role.ecs_instance.name
  policy_arn = local.ecs_instance_policies[count.index]
}

resource "aws_iam_instance_profile" "ecs_instance" {
  name = "${local.ecs_instance_role_name}-profile"
  role = aws_iam_role.ecs_instance.name

  lifecycle {
    create_before_destroy = true
  }
}
