# terraform-aws-container

![GitHub Release](https://img.shields.io/github/v/release/fadu-test-solutions/terraform-aws-container)
![GitHub](https://img.shields.io/github/license/fadu-test-solutions/terraform-aws-container?color=blue&style=flat-square)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white&style=flat-square)](https://github.com/pre-commit/pre-commit)

> [!NOTE]
> While this project is primarily managed in our Self-managed GitLab instance,
> we welcome external contributions through GitHub.

## About

Terraform module which creates resources for container services on AWS.

- [ecs-asg-cluster](./modules/ecs-asg-cluster): Terraform module to run ECS cluster, with ASG + Launch Template + Scaling policies via capacity provider.

## Development Environment

This project uses a devcontainer environment, which provides a consistent, pre-configured development setup for all contributors.

### Prerequisites

- [Docker](https://docs.docker.com/engine/install/)
- [Visual Studio Code](https://code.visualstudio.com/)
- [Remote - Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

### Getting Started

1. Clone the repository:

   ```bash
   git clone https://github.com/your-username/terraform-aws-container.git
   cd terraform-aws-container
   ```

2. Open the project in Visual Studio Code:

   ```bash
   code .
   ```

3. When prompted, click "Reopen in Container" or use the command palette (F1) and select "Remote-Containers: Reopen in Container".

4. VS Code will build the devcontainer and install all necessary dependencies.

## Contributing

We maintain this project in our Self-managed GitLab instance, but we welcome all contributions through GitHub:

1. For bug reports and feature requests:

   - Open an issue on GitHub
   - Use the provided issue templates
   - Be as detailed as possible in your description

2. For code contributions:
   - Fork the repository
   - Create a new branch for your changes
   - Submit a pull request
   - Follow our code style and commit message conventions
   - Ensure all tests pass

Our team will sync these contributions with our internal GitLab instance and maintain communication through GitHub.

## License

Provided under the terms of the [Apache License](LICENSE).
