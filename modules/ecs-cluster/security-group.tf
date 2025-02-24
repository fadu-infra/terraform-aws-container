module "ecs_security_group" {
  source = "git::git@gitlab.fadutec.dev:infra/devops/terraform-aws-network.git//modules/security-group?ref=feature/INFRAOPS-308"
  # source = "app.terraform.io/fadutec/network/aws//modules/security-group"

  name        = "${local.name}-sg"
  description = "ECS nodes for ${local.name}"
  vpc_id      = local.vpc_id
  tags        = local.tags

  ingress_rules = [
    {
      id         = "ingress_rule"
      protocol   = "-1"
      from_port  = 0
      to_port    = 0
      ipv4_cidrs = local.trusted_cidr_blocks
    }
  ]

  egress_rules = [
    {
      id         = "egress_rule"
      protocol   = "-1"
      from_port  = 0
      to_port    = 0
      ipv4_cidrs = ["0.0.0.0/0"]
    }
  ]
}
