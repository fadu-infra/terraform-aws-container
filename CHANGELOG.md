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
