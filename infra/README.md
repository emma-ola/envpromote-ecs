# Infrastructure — Terraform for ECS Deployment

This directory contains Terraform configuration for deploying the EnvPromote ECS application to AWS across multiple environments (dev, staging, production).

---

## Directory Structure

```
infra/
├── bootstrap/
│   ├── bootstrap-oidc/     # One-time OIDC provider setup
│   └── us-east-1/          # State Bucket setup for us-east-1 region
├── envs/
│   ├── dev/                # Dev environment
│   ├── staging/            # Staging environment
│   └── prod/               # Production environment
└── modules/
    ├── ecr/                       # ECR repository module
    ├── ecs-fargate-service/       # ECS Fargate service + ALB module
    └── github-oidc-role/          # IAM role for GitHub Actions OIDC
```

---

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0
- AWS account with permissions to create:
  - IAM roles and policies
  - ECS clusters, services, and task definitions
  - ECR repositories
  - VPC, subnets, load balancers, and security groups

---

## Bootstrap Steps

Before deploying any environment, you need to bootstrap your AWS account with two resources:

### Step 1: Create S3 Bucket for Terraform State (Optional but Recommended)

For production use, store Terraform state remotely in S3 instead of using local state files.

```bash
cd infra/bootstrap/us-east-1
terraform init
terraform apply -var="state_bucket_name=your-unique-bucket-name"
```

This creates:
- S3 bucket for Terraform state storage
- Versioning enabled on the bucket
- Server-side encryption (AES256)
- Public access blocked
- TLS-only access policy

**Note the bucket name** from the output — you'll use it to configure remote state in each environment.

### Step 2: Create GitHub OIDC Provider

Create the GitHub OIDC identity provider in your AWS account. This allows GitHub Actions to authenticate to AWS without long-lived credentials.

```bash
cd infra/bootstrap/bootstrap-oidc
terraform init
terraform plan
terraform apply
```

This creates the AWS IAM OIDC provider for `https://token.actions.githubusercontent.com`.

---

## Deploying an Environment

Each environment (dev, staging, prod) is independent and can be deployed separately.

### Step 1: Navigate to the environment directory

```bash
cd infra/envs/dev  # or staging, or prod
```

### Step 2: Update the `terraform.tfvars` file

```hcl
github_owner = "your-github-username-or-org"
github_repo  = "your-repo-name"
aws_region   = "your-aws-region"
```

### Step 3: Initialize Terraform

```bash
terraform init
```

### Step 4: Plan the deployment

```bash
terraform plan
```

### Step 5: Apply the configuration

```bash
terraform apply
```

### Step 6: Save outputs

After a successful apply, Terraform will output key values needed for GitHub Actions:

```
ecr_repository_url          = "123456789012.dkr.ecr.us-east-1.amazonaws.com/envpromote-ecs"
github_actions_role_arn     = "arn:aws:iam::123456789012:role/envpromote-gha-dev"
dev_alb_url                 = "http://envpromote-dev-alb-123456789.us-east-1.elb.amazonaws.com"
dev_ecs_cluster_name        = "envpromote-ecs-dev"
dev_ecs_service_name        = "envpromote-ecs-dev"
dev_task_execution_role_arn = "arn:aws:iam::123456789012:role/..."
```

---

## GitHub Actions Configuration

After deploying each environment, configure the following GitHub Environment secrets:

### For `dev`, `staging`, and `production` environments:

| Secret Name                   | Value from Terraform Output   |
|-------------------------------|-------------------------------|
| `AWS_REGION`                  | `us-east-1` (or your region)  |
| `AWS_ROLE_ARN`                | `github_actions_role_arn`     |
| `CONTAINER_NAME`              | `container-name`              |
| `ECR_REPOSITORY_URL`          | `ecr_repository_url `         |
| `ECS_CLUSTER`                 | `dev_ecs_cluster_name`        |
| `ECS_SERVICE`                 | `dev_ecs_service_name`        |
| `ECS_TASK_EXECUTION_ROLE_ARN` | `dev_task_execution_role_arn` |

---

## Terraform Modules

### `modules/ecr`
Creates an Amazon ECR repository for storing container images.

**Inputs:**
- `name` — repository name
- `tags` — resource tags

**Outputs:**
- `repository_arn`
- `repository_url`

---

### `modules/github-oidc-role`
Creates an IAM role that GitHub Actions can assume via OIDC.

**Inputs:**
- `github_owner` — GitHub org/user
- `github_repo` — repository name
- `allowed_branch` - allowed branch name
- `github_environment` — environment name (dev, staging, prod)
- `role_name` — IAM role name
- `ecr_repository_arn` — ARN of the ECR repository
- `tags` — resource tags

**Outputs:**
- `role_arn` — IAM role ARN for GitHub Actions

---

### `modules/ecs-fargate-service`
Creates a complete ECS Fargate service with:
- ECS cluster
- ECS service with deployment circuit breaker
- Application Load Balancer (ALB)
- Target group with health checks
- Security groups
- IAM roles (task execution, task role)
- CloudWatch log group

**Inputs:**
- `environment` — environment name
- `name` — service name
- `image` — container image URI
- `desired_count` — number of tasks
- `cpu` — task CPU units
- `memory` — task memory (MB)
- `tags` — resource tags
- `container_port` — container port

**Outputs:**
- `ecs_cluster_name`
- `ecs_service_name`
- `alb_dns_name`
- `task_execution_role_arn`
- `task_definition_family`

---

## Deployment Flow

1. **Bootstrap S3 state bucket** (one-time, optional but recommended)
2. **Bootstrap OIDC provider** (one-time)
3. **Deploy dev environment** → outputs role ARN, cluster name, etc.
4. **Configure GitHub Environments** with Terraform outputs
5. **Deploy staging environment** → repeat configuration
6. **Deploy production environment** → add approval gates in GitHub

---

## Cleanup

To destroy an environment:

```bash
cd infra/envs/dev  # or staging, or prod
terraform destroy
```

⚠️ **Warning:** This will delete all resources including the ECS cluster, ALB, and task definitions.

---

## Notes

- Each environment uses separate Terraform state (local by default)
- For production use, configure remote state (S3 + DynamoDB)
- ECS services are configured with deployment circuit breakers for automatic rollback
- All resources are tagged for cost tracking and resource management
- The ECR repository is shared across environments, but each environment has its own ECS service and task definition family

---

## Related

- [Main README](../README.md)
- [GitHub Actions Workflows](../.github/workflows)
- [Application Code](../app)
