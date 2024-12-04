# ecs-cluster

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.43.0 |
| <a name="provider_cloudinit"></a> [cloudinit](#provider\_cloudinit) | 2.3.3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.ecs_nodes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_ecs_capacity_provider.asg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_capacity_provider) | resource |
| [aws_ecs_cluster.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_cluster_capacity_providers.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster_capacity_providers) | resource |
| [aws_iam_instance_profile.ecs_node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.service_roles](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_launch_template.node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_security_group.ecs_nodes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_iam_policy_document.assume_role_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_ssm_parameter.ecs_ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.ecs_ami_arm64](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [cloudinit_config.config](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | (Required) Cluster name. | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | (Required) A list of subnet IDs. | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | (Required) The VPC ID. | `string` | n/a | yes |
| <a name="input_arm64"></a> [arm64](#input\_arm64) | ECS node architecture. Default is `amd64`. You can change it to `arm64` by activating this flag. If you do, then you should use corresponding instance types. | `bool` | `false` | no |
| <a name="input_asg_max_size"></a> [asg\_max\_size](#input\_asg\_max\_size) | The maximum size the auto scaling group (measured in EC2 instances). | `number` | `10` | no |
| <a name="input_asg_min_size"></a> [asg\_min\_size](#input\_asg\_min\_size) | The minimum size the auto scaling group (measured in EC2 instances). | `number` | `0` | no |
| <a name="input_ebs_disks"></a> [ebs\_disks](#input\_ebs\_disks) | A list of additional EBS disks. | <pre>map(object({<br>    volume_size           = string<br>    delete_on_termination = bool<br>  }))</pre> | `{}` | no |
| <a name="input_enabled_default_capacity_provider"></a> [enabled\_default\_capacity\_provider](#input\_enabled\_default\_capacity\_provider) | Enable default capacity provider strategy. | `bool` | `true` | no |
| <a name="input_instance_types"></a> [instance\_types](#input\_instance\_types) | ECS node instance types. Maps of pairs like `type = weight`. Where weight gives the instance type a proportional weight to other instance types. | `map(any)` | <pre>{<br>  "t3a.small": 2<br>}</pre> | no |
| <a name="input_lifecycle_hooks"></a> [lifecycle\_hooks](#input\_lifecycle\_hooks) | A list of lifecycle hook actions. See details at https://docs.aws.amazon.com/autoscaling/ec2/userguide/lifecycle-hooks.html. | <pre>list(object({<br>    name                    = string<br>    lifecycle_transition    = string<br>    default_result          = string<br>    heartbeat_timeout       = number<br>    role_arn                = string<br>    notification_target_arn = string<br>    notification_metadata   = string<br>  }))</pre> | `[]` | no |
| <a name="input_nodes_with_public_ip"></a> [nodes\_with\_public\_ip](#input\_nodes\_with\_public\_ip) | Assign public IP addresses to ECS cluster nodes. Useful when an ECS cluster hosted in internet facing networks. | `bool` | `false` | no |
| <a name="input_on_demand_base_capacity"></a> [on\_demand\_base\_capacity](#input\_on\_demand\_base\_capacity) | The minimum number of on-demand EC2 instances. | `number` | `0` | no |
| <a name="input_protect_from_scale_in"></a> [protect\_from\_scale\_in](#input\_protect\_from\_scale\_in) | The autoscaling group will not select instances with this setting for termination during scale in events. | `bool` | `true` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | Additional security group IDs. Default security group would be merged with the provided list. | `list(string)` | `[]` | no |
| <a name="input_spot"></a> [spot](#input\_spot) | Choose should we use spot instances or on-demand to populate ECS cluster. | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | `{}` | no |
| <a name="input_target_capacity"></a> [target\_capacity](#input\_target\_capacity) | The target utilization for the cluster. A number between 1 and 100. | `number` | `100` | no |
| <a name="input_trusted_cidr_blocks"></a> [trusted\_cidr\_blocks](#input\_trusted\_cidr\_blocks) | List of trusted subnets CIDRs with hosts that should connect to the cluster. E.g., subnets with ALB and bastion hosts. | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | A shell script will be executed at once at EC2 instance start. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_capacity_provider"></a> [capacity\_provider](#output\_capacity\_provider) | The name of the capacity provider, which is the same as the name for ASG. |
| <a name="output_ecs_cluster_details"></a> [ecs\_cluster\_details](#output\_ecs\_cluster\_details) | Details of the ECS cluster including ARN, ID, and name. |
| <a name="output_ecs_service_role"></a> [ecs\_service\_role](#output\_ecs\_service\_role) | The name and ARN of the ECS service role. |
| <a name="output_ecs_task_execution_role"></a> [ecs\_task\_execution\_role](#output\_ecs\_task\_execution\_role) | The name and ARN of the ECS default task execution role. |
| <a name="output_iam_instance_profile"></a> [iam\_instance\_profile](#output\_iam\_instance\_profile) | The ARN and name of the IAM instance profile. |
| <a name="output_iam_instance_role"></a> [iam\_instance\_role](#output\_iam\_instance\_role) | The ARN and name of the IAM instance role. |
| <a name="output_security_group"></a> [security\_group](#output\_security\_group) | The ID and name of the ECS nodes security group. |
<!-- END_TF_DOCS -->
