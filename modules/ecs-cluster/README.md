<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.10 |
| <a name="requirement_aws"></a> [aws](#requirement_aws) | >= 5.83 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider_aws) | 5.89.0 |
| <a name="provider_cloudinit"></a> [cloudinit](#provider_cloudinit) | 2.3.6 |

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_capacity_provider.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_capacity_provider) | resource |
| [aws_ecs_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_cluster_capacity_providers.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster_capacity_providers) | resource |
| [aws_iam_instance_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.ecs_instance_policy_ec2_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.task_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.ecs_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.task_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ecs_instance_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.task_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.task_exec_additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_launch_template.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_iam_policy_document.task_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.task_exec_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [cloudinit_config.this](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_subnet_ids"></a> [subnet_ids](#input_subnet_ids) | (Required) A list of subnet IDs. | `list(string)` | n/a | yes |
| <a name="input_ami_id"></a> [ami_id](#input_ami_id) | (Optional) The AMI ID to use for ECS nodes. If not provided, a default AMI will be used based on the architecture. | `string` | `""` | no |
| <a name="input_asg_max_size"></a> [asg_max_size](#input_asg_max_size) | (Optional)The maximum size the auto scaling group (measured in EC2 instances). | `number` | `10` | no |
| <a name="input_asg_min_size"></a> [asg_min_size](#input_asg_min_size) | (Optional) The minimum size the auto scaling group (measured in EC2 instances). | `number` | `0` | no |
| <a name="input_autoscaling_capacity_providers"></a> [autoscaling_capacity_providers](#input_autoscaling_capacity_providers) | Map of autoscaling capacity provider definitions to create for the cluster | `any` | `{}` | no |
| <a name="input_cloudwatch_log_group_kms_key_id"></a> [cloudwatch_log_group_kms_key_id](#input_cloudwatch_log_group_kms_key_id) | If a KMS Key ARN is set, this key will be used to encrypt the corresponding log group. Please be sure that the KMS Key has an appropriate key policy (https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html) | `string` | `null` | no |
| <a name="input_cloudwatch_log_group_name"></a> [cloudwatch_log_group_name](#input_cloudwatch_log_group_name) | Custom name of CloudWatch Log Group for ECS cluster | `string` | `null` | no |
| <a name="input_cloudwatch_log_group_retention_in_days"></a> [cloudwatch_log_group_retention_in_days](#input_cloudwatch_log_group_retention_in_days) | Number of days to retain log events | `number` | `90` | no |
| <a name="input_cloudwatch_log_group_tags"></a> [cloudwatch_log_group_tags](#input_cloudwatch_log_group_tags) | A map of additional tags to add to the log group created | `map(string)` | `{}` | no |
| <a name="input_cluster_configuration"></a> [cluster_configuration](#input_cluster_configuration) | The execute command configuration for the cluster | `any` | `{}` | no |
| <a name="input_cluster_name"></a> [cluster_name](#input_cluster_name) | Name of the cluster (up to 255 letters, numbers, hyphens, and underscores) | `string` | `""` | no |
| <a name="input_cluster_service_connect_defaults"></a> [cluster_service_connect_defaults](#input_cluster_service_connect_defaults) | Configures a default Service Connect namespace | `map(string)` | `{}` | no |
| <a name="input_cluster_settings"></a> [cluster_settings](#input_cluster_settings) | List of configuration block(s) with cluster settings. For example, this can be used to enable CloudWatch Container Insights for a cluster | `any` | <pre>[<br/>  {<br/>    "name": "containerInsights",<br/>    "value": "enabled"<br/>  }<br/>]</pre> | no |
| <a name="input_create"></a> [create](#input_create) | Determines whether resources will be created (affects all resources) | `bool` | `true` | no |
| <a name="input_create_cloudwatch_log_group"></a> [create_cloudwatch_log_group](#input_create_cloudwatch_log_group) | Determines whether a log group is created by this module for the cluster logs. If not, AWS will automatically create one if logging is enabled | `bool` | `true` | no |
| <a name="input_create_task_exec_iam_role"></a> [create_task_exec_iam_role](#input_create_task_exec_iam_role) | Determines whether the ECS task definition IAM role should be created | `bool` | `false` | no |
| <a name="input_create_task_exec_policy"></a> [create_task_exec_policy](#input_create_task_exec_policy) | Determines whether the ECS task definition IAM policy should be created. This includes permissions included in AmazonECSTaskExecutionRolePolicy as well as access to secrets and SSM parameters | `bool` | `true` | no |
| <a name="input_default_capacity_provider_use_fargate"></a> [default_capacity_provider_use_fargate](#input_default_capacity_provider_use_fargate) | Determines whether to use Fargate or autoscaling for default capacity provider strategy | `bool` | `true` | no |
| <a name="input_ebs_disks"></a> [ebs_disks](#input_ebs_disks) | (Optional) A list of additional EBS disks.<br/>    (Optional) `volume_size` - The size of the EBS disk in GB. Range: 1-16384<br/>    (Optional) `delete_on_termination` - Whether the volume should be destroyed on instance termination | <pre>map(object({<br/>    volume_size           = optional(number)<br/>    delete_on_termination = optional(bool)<br/>  }))</pre> | `{}` | no |
| <a name="input_fargate_capacity_providers"></a> [fargate_capacity_providers](#input_fargate_capacity_providers) | Map of Fargate capacity provider definitions to use for the cluster | `any` | `{}` | no |
| <a name="input_instance_types"></a> [instance_types](#input_instance_types) | (Optional) ECS node instance types. Maps of pairs like `type = weight`. Where weight gives the instance type a proportional weight to other instance types. | `map(number)` | <pre>{<br/>  "t3a.small": 2<br/>}</pre> | no |
| <a name="input_lifecycle_hooks"></a> [lifecycle_hooks](#input_lifecycle_hooks) | (Optional) A list of lifecycle hook actions. See details at https://docs.aws.amazon.com/autoscaling/ec2/userguide/lifecycle-hooks.html.<br/>    (Required) `name` - The name of the lifecycle hook.<br/>    (Required) `lifecycle_transition` - The lifecycle transition.<br/>    (Optional) `default_result` - The default result of the lifecycle hook.<br/>    (Optional) `heartbeat_timeout` - The heartbeat timeout.<br/>    (Optional) `role_arn` - The ARN of the IAM role.<br/>    (Optional) `notification_target_arn` - The ARN of the notification target.<br/>    (Optional) `notification_metadata` - The metadata of the notification. | <pre>list(object({<br/>    name                    = string<br/>    lifecycle_transition    = string<br/>    default_result          = optional(string)<br/>    heartbeat_timeout       = optional(number)<br/>    role_arn                = optional(string)<br/>    notification_target_arn = optional(string)<br/>    notification_metadata   = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_on_demand_base_capacity"></a> [on_demand_base_capacity](#input_on_demand_base_capacity) | (Optional) The minimum number of on-demand EC2 instances. | `number` | `0` | no |
| <a name="input_protect_from_scale_in"></a> [protect_from_scale_in](#input_protect_from_scale_in) | (Optional) The autoscaling group will not select instances with this setting for termination during scale in events. | `bool` | `true` | no |
| <a name="input_public"></a> [public](#input_public) | Boolean to determine if the instances should have a public IP address | `bool` | `false` | no |
| <a name="input_security_group_ids"></a> [security_group_ids](#input_security_group_ids) | (Optional) Additional security group IDs. Default security group would be merged with the provided list. | `list(string)` | `[]` | no |
| <a name="input_snapshot_id"></a> [snapshot_id](#input_snapshot_id) | (Optional) The snapshot ID to use to create ECS nodes. | `string` | `""` | no |
| <a name="input_spot"></a> [spot](#input_spot) | (Optional) Choose should we use spot instances or on-demand to populate ECS cluster. | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_task_exec_iam_role_description"></a> [task_exec_iam_role_description](#input_task_exec_iam_role_description) | Description of the role | `string` | `null` | no |
| <a name="input_task_exec_iam_role_name"></a> [task_exec_iam_role_name](#input_task_exec_iam_role_name) | Name to use on IAM role created | `string` | `null` | no |
| <a name="input_task_exec_iam_role_path"></a> [task_exec_iam_role_path](#input_task_exec_iam_role_path) | IAM role path | `string` | `null` | no |
| <a name="input_task_exec_iam_role_permissions_boundary"></a> [task_exec_iam_role_permissions_boundary](#input_task_exec_iam_role_permissions_boundary) | ARN of the policy that is used to set the permissions boundary for the IAM role | `string` | `null` | no |
| <a name="input_task_exec_iam_role_policies"></a> [task_exec_iam_role_policies](#input_task_exec_iam_role_policies) | Map of IAM role policy ARNs to attach to the IAM role | `map(string)` | `{}` | no |
| <a name="input_task_exec_iam_role_tags"></a> [task_exec_iam_role_tags](#input_task_exec_iam_role_tags) | A map of additional tags to add to the IAM role created | `map(string)` | `{}` | no |
| <a name="input_task_exec_iam_role_use_name_prefix"></a> [task_exec_iam_role_use_name_prefix](#input_task_exec_iam_role_use_name_prefix) | Determines whether the IAM role name (`task_exec_iam_role_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_task_exec_iam_statements"></a> [task_exec_iam_statements](#input_task_exec_iam_statements) | A map of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for custom permission usage | `any` | `{}` | no |
| <a name="input_task_exec_secret_arns"></a> [task_exec_secret_arns](#input_task_exec_secret_arns) | List of SecretsManager secret ARNs the task execution role will be permitted to get/read | `list(string)` | <pre>[<br/>  "arn:aws:secretsmanager:*:*:secret:*"<br/>]</pre> | no |
| <a name="input_task_exec_ssm_param_arns"></a> [task_exec_ssm_param_arns](#input_task_exec_ssm_param_arns) | List of SSM parameter ARNs the task execution role will be permitted to get/read | `list(string)` | <pre>[<br/>  "arn:aws:ssm:*:*:parameter/*"<br/>]</pre> | no |
| <a name="input_use_snapshot"></a> [use_snapshot](#input_use_snapshot) | (Optional) Use snapshot to create ECS nodes. | `bool` | `false` | no |
| <a name="input_user_data"></a> [user_data](#input_user_data) | (Optional) A shell script will be executed at once at EC2 instance start. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output_arn) | ARN that identifies the cluster |
| <a name="output_autoscaling_capacity_providers"></a> [autoscaling_capacity_providers](#output_autoscaling_capacity_providers) | Map of autoscaling capacity providers created and their attributes |
| <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch_log_group_arn](#output_cloudwatch_log_group_arn) | ARN of CloudWatch log group created |
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch_log_group_name](#output_cloudwatch_log_group_name) | Name of CloudWatch log group created |
| <a name="output_cluster_capacity_providers"></a> [cluster_capacity_providers](#output_cluster_capacity_providers) | Map of cluster capacity providers attributes |
| <a name="output_id"></a> [id](#output_id) | ID that identifies the cluster |
| <a name="output_name"></a> [name](#output_name) | Name that identifies the cluster |
| <a name="output_task_exec_iam_role_arn"></a> [task_exec_iam_role_arn](#output_task_exec_iam_role_arn) | Task execution IAM role ARN |
| <a name="output_task_exec_iam_role_name"></a> [task_exec_iam_role_name](#output_task_exec_iam_role_name) | Task execution IAM role name |
| <a name="output_task_exec_iam_role_unique_id"></a> [task_exec_iam_role_unique_id](#output_task_exec_iam_role_unique_id) | Stable and unique string identifying the task execution IAM role |
<!-- END_TF_DOCS -->
