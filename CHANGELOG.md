## [0.4.0](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/compare/v0.3.0...v0.4.0) (2025-05-12)

### 🚀 New Features

* add CloudWatch alarm configuration for ECS service scaling policies ([20858c7](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/20858c797593111253724d34034d1d664826de40))
* add default_execute_command_configuration variable for enhanced ECS cluster logging and command execution settings ([3b2c642](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/3b2c642919aa56e0a68d943c8e384278e76dc56f))
* add ECS container definition module with comprehensive configuration options ([03e8ffd](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/03e8ffd9851b5615f8f21ef4591a19aaa4c8dcaa))
* add ECS service scaling policies configuration with support for TargetTracking and StepScaling ([7502b77](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/7502b77a6ba55ce4436d138d270357e755fec144))
* add IAM role and policy definitions for ECS task execution and tasks, enhancing security and permissions management ([6cb08c9](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/6cb08c99f5db3f22a55fb59be0221d01b89ca51b))
* add IAM role outputs for ECS instance and task execution roles ([cb8bc5c](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/cb8bc5cc13ebfb22add7593dd5c0e7b5016f1e23))
* add managed EBS volume configuration support for ECS service ([6811e09](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/6811e095bcf2ea4e38c84386db8b65ead8270c6d))
* add module tags support for ECS container definition resources ([10ba2ca](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/10ba2ca25babc7f4acbaff0d83d56d89834513ea))
* add module tags support for ECS resources ([00189f3](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/00189f3372edc1ef75d602ea892d2398fea12fdc))
* add nullable attribute to ECS module variables for improved type safety ([2a25ae4](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/2a25ae4b7a1eecbfd62486c5e5f150f8ce75eda4))
* add service autoscaling configuration to enable or disable scaling policies in ECS service ([2f652b8](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/2f652b822c96b29e4cb036cc968ca8ee5e98c96c))
* enhance ECS cluster capacity provider configuration with improved variable definitions and validation ([864c1a3](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/864c1a34378c9dfde24205bbccd4c1e55171292b))
* enhance ECS cluster configuration with detailed execute command settings and validation ([82b962d](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/82b962db8e6b10fcab79d252e77631b45ce819c9))
* implement IAM roles and policies for ECS service and task execution ([bf7a4ab](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/bf7a4abcca101e1cf79ae37df29e96db95cac6b5))
* introduce container definition template and enhance ECS task definition with improved variable configurations ([e1a1d2e](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/e1a1d2e3542e624e5152c3636981c8cc01cdf208))
* migrate ECS instance policies and roles to IAM resource file ([c22f977](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/c22f97726013b16b91334d1ddf780bb128fa2bb0))
* update cluster_service_connect_defaults variable to use a list of objects for improved configuration ([e459492](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/e459492815e08b07034a8389409a93b754e001f2))
* update ECS module to use a unified name variable and versioning ([f87c4c9](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/f87c4c98c1745516f51bc7b65974e92e89d63672))

### 🐛 Bug Fixes

* correct status option in autoscaling_capacity_provider variable documentation ([72aa39b](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/72aa39be7c81aad117536ae44139f41bf0d4156f))
* enhance service_connect_configuration validation and ensure required fields are enforced ([bac82a2](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/bac82a2ef1edd1ab4df8248706431828caf778c4))
* improve service_connect_configuration handling by checking for empty map length ([11d45aa](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/11d45aa194512acb8e08f120c63b8b2af20cee75))
* modify service_connect_configuration to set default enabled value to [secure] and improve client_alias handling ([ead2cf5](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/ead2cf55d18612e20bd3652935276e581929ac01))
* remove default value for enabled field in service_connect_configuration variable ([39dd89f](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/39dd89fd651f9966d603c8e8229030ccc1b46931))
* update auto_scaling_group_arn reference in ECS capacity provider configuration ([430a1f9](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/430a1f95f1b692c3577c1888fae927dd555871b3))
* update autoscaling_capacity_provider variable documentation to reflect required name field ([618cdf0](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/618cdf0e237cb7202d861bb95ab72d72b8e6dece))
* update client_alias handling in ECS service configuration to avoid null reference ([e6f4f20](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/e6f4f20245e8a6b0ca56a52890078cbe62f7fd2f))
* update CloudWatch alarm configuration ([830d1c9](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/830d1c926f4892ff446cdb2d24be62ae4415b38f))
* update default ephemeral storage size in ECS task definition module ([48e6b1f](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/48e6b1f6c29e410e62476b3dc35fa25566068a78))
* update default ephemeral storage size in ECS task definition module ([e62f1e5](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/e62f1e5c8ed8741ea7a2055b6092fc61a29df6ae))
* update security group and subnet variable names in ECS service module ([abf174a](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/abf174a7f8a26dbf71adce96c3aee2029732b041))
* update service_connect_configuration logic to handle empty map case correctly ([e078706](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/e0787068f15b267cafc8c0c34efd9bea397876aa))

### 🧰 Maintenance

* add directory variable for CI configuration ([8b636da](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/8b636dac2bf9ef7c8b68e63ef088071e43dce11a))
* add package manager variable for Dependabot configuration ([d4c395a](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/d4c395a6eb114d8e94cb69dc49de5ffb3f6597b5))
* add versions.tf to ECS cluster and service modules ([80b966b](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/80b966bd89973b9eee3104f24d208c35a9a3761c))
* remove module_tags_enabled variable from ECS modules ([408b5ed](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/408b5ed80521578786a447c103083679ba8d7db4))
* update .gitignore to exclude Terraform lock files in modules and remove ecs-service lock file ([f00f394](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/f00f39495ddf7f3a11cd5c1c6769b873f533d2eb))
* update GitLab CI rules and workflow includes ([03460e1](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/03460e107bfff2336ecfd3cc218ce05d8cc7492e))

### 🚜 Refactor

* adjust ECS task definition modes based on Fargate compatibility ([a46f4c4](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/a46f4c4287eeb43ad48a4799275deae0a07ead71))
* complete overhaul of ECS service module with comprehensive IAM and task definition support ([a787b0e](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/a787b0ea5e03d3643e988cb335a557e8e7646bd9))
* conditionally create EC2 resources for ECS cluster based on capacity providers ([0e17c15](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/0e17c15c1a6487dd56dce6f6c4b42b71ed2ff171))
* consolidate EC2 resources into a single file ([5c63dec](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/5c63dec19130fe4ac3c80c8e451dba970a12c707))
* consolidate ECS cluster module variables into a single comprehensive configuration object ([eae00dc](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/eae00dc7e868bfd1c3a9fb18d9b44ff39c9738e9))
* consolidate ECS service IAM role configuration into a single module ([1bb3236](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/1bb3236e90e858723f9e72c68c3e83f0b286b4e8))
* consolidate IAM resources into main.tf for ECS cluster module ([b75cb97](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/b75cb976a50c91b59d389e0ee3dcbb7c84dc455e))
* enhance container_dependencies variable with validation for condition values ([8eed0fc](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/8eed0fcec2d6c52d6ec0cdb12d5cc7cfb5bf3b69))
* enhance ECS cluster module variables with validation and nullability ([ff057da](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/ff057dab9991d7e137e07c32d80ae33576845f1e))
* enhance ECS cluster module with comprehensive configuration and IAM support ([2785393](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/27853937595093d02ab00b8235af8e0026bd9e74))
* enhance ECS service configuration by updating variable definitions and restructuring resource references ([5be8567](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/5be8567c291ea90ea2fef965bb44434aec35717b))
* enhance ECS service module variable descriptions and validation ([61d033b](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/61d033be11dfb2eb7ee7914750298db16170d006))
* enhance ECS service module with dynamic IAM roles and service configuration ([0022934](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/0022934fa3a265b36bad17cf389ddf468e6508f9))
* enhance ECS task definition variable configurations by adding validation rules and setting nullable properties ([cf22468](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/cf2246809e44746c54de9bbf7a0fe2d3af989b27))
* enhance IAM role and variable definitions in ECS service module ([087e7b6](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/087e7b6d84ccf67e33be0324b9b1c5d939c8f060))
* enhance readability and organization of ECS cluster and container definition modules with improved comments and variable descriptions ([703f1a0](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/703f1a01c7e206828d6a4502da5e6202adf0c758))
* enhance variable definitions and descriptions in ECS service module for improved clarity and structure ([d85cf58](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/d85cf5811e3856c87cf61b1374992c51d4071899))
* enhance variable validation in ECS modules by incorporating try function for improved error handling ([929e187](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/929e187a30f11a840f5cc13665fb84a9e512269e))
* implement runtime_platform block directly in ECS task definition for improved clarity ([66b524b](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/66b524b3eae7dc308857969bbd5eaccb989b3e0f))
* implement runtime_platform block directly in ECS task definition for improved clarity ([d39b755](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/d39b755e633ad45e461608c61856f4249931fde3))
* improve ECS container definition module with enhanced type safety and validation ([c871414](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/c8714143a1a82ec5ba7a3fe4a15e1596f8ea775f))
* improve ECS service module configuration and variable structure ([506df4b](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/506df4bdd4a911f5d171d7ba05b68f60c3704bcb))
* improve ECS task definition module by simplifying variable handling and enhancing log group configuration ([03d5060](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/03d50607c4bada2c9d6243b382680b0e78d36f87))
* improve log configuration handling and enhance variable descriptions for ECS container definition module ([76b92c6](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/76b92c6b80572899af19047786128bdb35d1e5d4))
* improve organization and clarity of ECS service module with enhanced comments and variable definitions ([421078e](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/421078eaa26697e0b954ffe6988b6e7bdf0f3f7f))
* improve variable definitions and logic for ECS cluster autoscaling and IAM roles ([9617d48](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/9617d48ed6a495e8ad6f0f93764b475fd567f1eb))
* migrate ECS cluster security group to modular security group ([b30a77d](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/b30a77d74c747a743c887d9a4f42067da686b43b))
* modify module structure ([0afae84](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/0afae843f4c957b21b84152940ee1d6d469ae563))
* move ECS security group configuration to main.tf ([55df078](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/55df07889043a8d106d6d0a5baad5709dec28167))
* move ECS service and task IAM roles to separate module ([b5fe7c2](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/b5fe7c21ec460bbffc6773d1a68c314dad5bf663))
* move variable declaration ([eebc126](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/eebc126b0796f552aca43119e7b7cc208e09de50))
* remove autoscaling and IAM role configurations from ECS cluster module ([a7f8628](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/a7f8628360f3c1a31acf5e87a12fdafc86b6ee16))
* remove commented-out code in ECS service and task definition modules ([f6f582b](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/f6f582b183472e7d25f1d1844f228e5029367713))
* remove commented-out tag_specifications block from ECS service configuration ([05ce8f2](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/05ce8f2d7e0331c2f15d590ea3ef3e6090d734d9))
* remove container definition template and streamline ECS task definition variable handling ([497f818](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/497f8180cab65542f5902d59d6c2d779e994feb7))
* remove IAM role and CloudWatch log group configurations from ECS task definition module ([4e97c41](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/4e97c41c91433d4326ab3d50693b917823a8394c))
* remove IAM role creation and related outputs from ECS service module ([44d0f8c](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/44d0f8cc4a8be90f098bc0afe669d16f640076e9))
* remove IAM role definitions and outputs from ECS cluster module ([2fd7d4f](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/2fd7d4f98860c7db04d20d3f4802006aca9b7503))
* remove IAM role variables from ECS service module ([48a4cdd](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/48a4cdd1a7bc9c9dc1e0687436b2549fa8dd64c6))
* remove security group resource from ECS cluster module ([8439c7b](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/8439c7bfef974020687b417ebfc47d286667a235))
* remove task execution and tasks IAM role definitions and outputs from ECS service module for simplification ([a862c3d](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/a862c3d36548d12b302a0b1dba90ff60d9c949ed))
* remove unused ECS service module configuration options ([4d5a7a5](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/4d5a7a5cbd9969ee90f6256aacb6c60d6cd20b82))
* remove unused ECS service module configuration options ([171d6d1](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/171d6d1560a0bae77a38d5dc30f19420123bdfda))
* remove unused FSx settings ([fe1ed8c](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/fe1ed8c5ff0206d46eaa5da28b28424904a4f2fb))
* remove variable related to resource creation and update output references ([71c6ac4](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/71c6ac4be302b9a7318e892b4d5c22e3fbb75f36))
* rename cluster_settings variable to container_insights_settings ([962fed0](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/962fed0cb31c86f8c809e068ecb36614a9ca693f))
* rename ECS cluster resource to follow consistent naming convention ([83ddcbc](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/83ddcbc18fb767a0e727e8f12a36cff8f2ba147a))
* rename module name ([5e01df2](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/5e01df2f29e4c0e9e2db82772b6fbd8bf3f9956b))
* rename resource file name ([025cb6f](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/025cb6f982a43d039a5b4c45115cc0f2d589d109))
* rename resource name ([fb98d58](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/fb98d584adb211f664401d9732daff0b0ceaccaa))
* rename terraform file name ([77efa72](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/77efa729e37d7a77784baa6dd6f9274b8e42eccc))
* simplify autoscaling resource count logic using local variable ([c79bdd5](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/c79bdd5433062c147cbb8556c0b9700888c5df5a))
* simplify ECS service configuration by removing null handling for various attributes ([d3f88fb](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/d3f88fbe46631f02f78381cffa8dac2a84014553))
* standardize ECS instance IAM resource naming ([ffe51bd](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/ffe51bd6d92698de84e978d712fc7c82a2f7dc88))
* standardize optional variable definitions by removing null defaults ([9ccf555](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/9ccf5558f1451e1ba6b2938c45d9e601baf7f4b0))
* standardize variable descriptions in ECS cluster and task definition modules ([d6e0952](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/d6e095247cc49f413e457f707901e265920b4735))
* streamline IAM policy document handling and variable definitions in ECS modules ([78897bb](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/78897bbc29cbf4ad41701f63ab455ab1144be57f))
* streamline variable descriptions in ECS cluster module for clarity and consistency ([fb712b4](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/fb712b40ff3c12b2e11befe5570fb30413bf1f86))
* streamline variable descriptions in ECS cluster module for clarity and consistency ([41aea4f](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/41aea4fdbb463481677a5a7e12be9e1772a91a37))
* update autoscaling capacity provider implementation for ECS module ([ce556e4](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/ce556e462ec112cafbfb9d6305d1aa37f6238b94))
* update AWS provider version and enhance CloudWatch log configuration structure in ECS service module ([8857364](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/8857364c5302cab4c3fc98b75ae3eab3c3b79d48))
* update cluster_name variable description in ECS service ([4645c1f](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/4645c1f1d6315f7577b12c223aabb94382fff2ec))
* update ECS service module to use plural load balancer variable and simplify deployment circuit breaker configuration ([20b96ac](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/20b96ac1d2023b3502ceb6bb4cd0b9e69f49d851))
* update ECS service scaling policies to support StepScaling and remove unused SimpleScaling configuration ([eea259f](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/eea259fd035fa0feac5ce7f42a50269bed879ef8))
* update ECS task definition to include configure_at_launch in volume settings ([2897c2b](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/2897c2bd9cc32a310f334dc7cf0255b7b696dd63))
* update firelens_configuration variable ([58ccbb1](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/58ccbb11718a9e79318af2954bd00527734df0af))
* update IAM role handling in ECS service module to support conditional role creation ([ab3688c](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/ab3688cc790eebaf34f3c82577b91ced7b6c2aad))
* update runtime_platform variable to allow null values and adjust dynamic block handling ([8067777](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/80677777a6b9e1cba9eaae2cb4be59b6f902d324))
* update runtime_platform variable to allow null values and adjust dynamic block handling ([4023059](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/402305968dc80311fa63dd41cadb184037d322a8))
* update Terraform docs generation to support multiple modules ([61fdd81](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/61fdd819ad466dc189eede482df63099d3f33554))
* update validation in hostname variable ([ff90c1a](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/ff90c1a4efd86cf90a02815e487e51c242b88548))
* update volume configuration options in ECS task definition with detailed descriptions ([51e32e8](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/51e32e86054063a12c2f1e06a0750abb8f6262fb))

### 📚 Documentation

* update descriptions for min_capacity and max_capacity variables ([c39d461](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/c39d4613eb895dcd7d8b0e19c1647998295d5ad9))
* update load balancer variable descriptions in ECS service module for clarity on ELB and ALB/NLB requirements ([0aed05e](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/0aed05e5d9aff4677a5ea117f435e230a6edbbb3))
* update README files for ECS modules ([2ef2aab](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/2ef2aabeb2fb63aeb496094ac5e3eefff80b81ff))

## [0.3.0](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/compare/v0.2.1...v0.3.0) (2025-01-20)

### 🚀 New Features

* add dependabot components ([4e8f020](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/4e8f020ea5e2ac21282abe44d8fbd5030ff9e767))
* refactoring ci pipelines using semantic-release ([04b68c4](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/04b68c4adb2d170aa24f2063c21e9aeab3f43793))
* remove unused files for using semantic-release ([4df074c](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/4df074cddd76c4c55c3af0027ea676ec39edd09f))

### 🐛 Bug Fixes

* correct GitLab pre-defined variable name ([ee04861](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/ee0486132456429f9052014c36c43961e87989db))

### 🧰 Maintenance

* apply latest project template ([839cc01](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/839cc015bbf92eed6586302b9740e97dd94d5adf))
* change github repository name ([33150b8](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/33150b863ea90d3f70700cb90592bbd43e8c0462))
* change github token variables ([d5fdc19](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/d5fdc190f5840405f4f3c7b67988c0c70200e052))
* change job name to semantic-release ([9dcc21e](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/9dcc21e5533feba62d4190c5e1254568bbb69551))
* change to github pat token ([96b8f18](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/96b8f185e77bba55f050888118f3d60dc22a81a2))
* remove unused stages(docs) ([2f8f5b2](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/2f8f5b245fe48a16b32416dce5c81205c4ea3626))
* update GitLab CI and Dependabot configurations ([b4d701b](https://gitlab.fadutec.dev/infra/devops/terraform-aws-container/commit/b4d701b3cef43f7dafbc50a41cb58c2f29d4ebbc))

# Changelog

All notable changes to this project will be documented in this file.

## [0.2.1] - 2025-01-10

### 🚀 New Features

- Add rules to release workflow (effa761)
- Add terraform-docs file (f6005d0)

### 🔧 CI changes

- Update terraform-docs pipeline trigger conditions (869af0a)

### 🧰 Maintenance

- Enhance terraform-docs workflow with additional options (537ea6c)
- Add stages for ci configuration (9a0b00b)
- Fix release workflow rules to include a 'never' condition (457708b)
- Remove changes variables (9a16068)
- Update terraform-docs workflow to use variables (8aff250)
- Remove workflow rules and include terraform-docs workflow (40c0744)

### 🚜 Refactor

- Change workflow rules (dadbcd2)
- Add comments for logging in pipeline (e305c87)
- Add comments in pipeline (9d4bcb4)
- Change variables in pipeline (933991f)
- Update variables in pipeline (1c88551)
- Update workflow rules in pipeline (48ebb71)
- Remove pipeline rules for release tags (9601280)
- Add pipeline rules for release tags (c402330)
- Remove security commit parser from cliff.toml (8656e6a)
- Improve json handling in workflow (e8c9b18)

### 📚 Documentation

- Update module documentation for modules/ecs-asg-cluster [skip ci] (0d85345)
- Update module documentation for modules/ecs-asg-cluster [skip ci] (74ade31)

### 💼 Other

- Update CHANGELOG.md for version v0.2.0 (01d8c0d)
## [0.2.0] - 2024-12-23

### 🐛 Bug Fixes

- Update CHANGELOG.md upload method in release workflow to include base64 encoding for content (3d09f6f)
- Update CHANGELOG.md upload method in release workflow to use base64 encoded content (928cc94)
- Correct indentation in GitLab CI release workflow configuration (79fcefd)

### 🔧 CI changes

- Add GitLab CI configuration and update release workflow rules (b1f493b)

### 🧰 Maintenance

- Update release workflow to include CHANGELOG.md in changelog generation (ec7eda0)
- Update release workflow to generate release notes and changelog files with improved structure (e6cbc7c)
- Simplify RELEASE.md generation in release workflow by removing unnecessary echo commands (5982ee4)
- Update changelog generation in release workflow to include only the latest changes (8345b75)
- Update release workflow to generate comprehensive RELEASE.md with changelog and release notes (5424c64)

### 🚜 Refactor

- Streamline release workflow by removing prepare stage and updating changelog upload method (ae7ba03)

### 💼 Other

- Update CHANGELOG.md for version v0.2.0 (c84ee6a)
- Add changelog for version v0.2.0 (f8ff011)
- Add project standardization configurations (2b1377e)
## [0.1.9] - 2024-12-11

### 🚀 New Features

- Add AmazonECSManaged tag in auto scaling group (d04a77f)
## [0.1.8] - 2024-12-02

### 🐛 Bug Fixes

- Fix : Replace managed_policy_arns with aws_iam_role_policy_attachment (693d39f)
## [0.1.1] - 2024-05-06

### 🚀 New Features

- Add snapshot with ebs_disks (092ff8b)
## [0.1.0] - 2024-03-31

### 💼 Other

- Initial commit (f244d82)
<!-- generated by git-cliff -->
