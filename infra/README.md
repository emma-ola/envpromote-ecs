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
    ├── github-oidc-role/          # IAM role for GitHub Actions OIDC
    └── sns-topic/                 # SNS topic for alarm notifications
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
- ECS cluster with Container Insights
- ECS service with deployment circuit breaker
- Application Load Balancer (ALB)
- Target group with health checks
- Security groups
- IAM roles (task execution, task role)
- CloudWatch log group
- CloudWatch alarms (CPU, memory, unhealthy targets, task count, response time)

**Inputs:**
- `environment` — environment name
- `name` — service name
- `image` — container image URI
- `desired_count` — number of tasks
- `cpu` — task CPU units
- `memory` — task memory (MB)
- `tags` — resource tags
- `container_port` — container port
- `enable_alarms` — enable CloudWatch alarms (default: false)
- `alarm_sns_topic_arn` — SNS topic ARN for alarm notifications

**Outputs:**
- `ecs_cluster_name`
- `ecs_service_name`
- `alb_dns_name`
- `task_execution_role_arn`
- `task_definition_family`

---

### `modules/sns-topic`
Creates an SNS topic for CloudWatch alarm notifications.

**Inputs:**
- `name` — SNS topic name
- `display_name` — display name for notifications
- `enable_encryption` — enable KMS encryption (default: true)
- `tags` — resource tags

**Outputs:**
- `topic_arn` — SNS topic ARN
- `topic_name` — SNS topic name
- `topic_id` — SNS topic ID

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

## Slack Alarm Notifications

CloudWatch alarms can send notifications to Slack via AWS Chatbot. Each environment creates an SNS topic that receives alarm notifications.

### Setup AWS Chatbot (One-time per environment)

After deploying an environment, configure AWS Chatbot to route SNS notifications to Slack:

1. **Get SNS Topic ARN from Terraform output:**
   ```bash
   cd infra/envs/dev  # or staging, or prod
   terraform output alarm_topic_arn
   ```

2. **Configure AWS Chatbot in AWS Console:**
   - Navigate to AWS Chatbot → https://console.aws.amazon.com/chatbot
   - Click "Configure new client" → Select "Slack"
   - Authorize AWS Chatbot to access your Slack workspace
   - Click "Configure new channel"
   - Select your Slack channel (e.g., `#aws-alarms-dev`)
   - Add the SNS topic ARN from step 1
   - Configure IAM permissions (use default CloudWatch read permissions)
   - Click "Configure"

3. **Repeat for each environment** (dev, staging, prod) with separate Slack channels

### Testing Alarm Notifications

To test that alarms are properly configured:

1. **Trigger a test alarm manually:**
   ```bash
   aws cloudwatch set-alarm-state \
     --alarm-name "envpromote-ecs-dev-high-cpu" \
     --state-value ALARM \
     --state-reason "Testing Slack notifications"
   ```

2. **Check your Slack channel** for the alarm notification

3. **Reset the alarm state:**
   ```bash
   aws cloudwatch set-alarm-state \
     --alarm-name "envpromote-ecs-dev-high-cpu" \
     --state-value OK \
     --state-reason "Test completed"
   ```

### Available Alarms

Each environment has the following CloudWatch alarms (when `enable_alarms = true`):

- **High CPU Utilization** — triggers when average CPU > 80% for 2 consecutive periods
- **High Memory Utilization** — triggers when average memory > 80% for 2 consecutive periods
- **Unhealthy Target Count** — triggers when unhealthy targets > 0 for 2 consecutive periods
- **Low Running Task Count** — triggers when running tasks < desired count for 2 consecutive periods
- **High Target Response Time** — triggers when average response time > 2 seconds for 2 consecutive periods

---

## Notes

- Each environment uses separate Terraform state (local by default)
- For production use, configure remote state (S3 + DynamoDB)
- ECS services are configured with deployment circuit breakers for automatic rollback
- All resources are tagged for cost tracking and resource management
- The ECR repository is shared across environments, but each environment has its own ECS service and task definition family
- CloudWatch alarms send notifications to environment-specific SNS topics
- AWS Chatbot must be configured manually (cannot be fully automated with Terraform)

---

## Related

- [Main README](../README.md)
- [GitHub Actions Workflows](../.github/workflows)
- [Application Code](../app)
