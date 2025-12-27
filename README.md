# EnvPromote ECS

Promotion-based CI/CD for Amazon ECS using GitHub Actions, Terraform, and immutable artifacts

## 📌 Overview

EnvPromote ECS is a production-grade CI/CD system that demonstrates how to safely deploy containerized applications to Amazon ECS using immutable artifact promotion instead of environment-specific builds.

The system builds a container image once, pushes it to Amazon ECR, and promotes the same image digest across dev → staging → production using GitHub Actions, with approval gates, automated rollback, and full auditability.

This mirrors how engineering teams reduce deployment risk and eliminate configuration drift.

## ❗ Problem / Context

In many teams, deployments suffer from:

- environment-specific pipelines
- manual promotion steps
- rebuilding the same code for each environment
- lack of clear release ownership
- unsafe "latest" image deployments

These practices increase:

- deployment risk
- debugging time
- production incidents
- audit complexity

## 🎯 Goals

- Build once, deploy everywhere
- Reduce human error in deployments
- Enforce clear promotion gates
- Make deployments deterministic and auditable
- Use modern cloud-native best practices (OIDC, IaC, immutable images)

## 💡 Solution Summary

This project implements a promotion-based CI/CD pipeline with the following characteristics:

- Single build → image pushed to ECR
- Promotion by image digest, not tag
- Separate ECS services and task definition families per environment
- GitHub Environments for scoped secrets and approvals
- Reusable GitHub Actions workflows
- Automatic rollback on failed health checks
- Promotion history recorded per deployment

## 🏗️ Architecture (High Level)

**GitHub Actions**
- CI build & push with security scanning
- Reusable deploy workflow
- Manual promotion workflows
- Automated testing with Jest

**Amazon ECR**
- Single repository
- Immutable image digests
- Vulnerability scanning with Trivy

**Amazon ECS (Fargate)**
- Separate clusters/services per environment
- Deployment circuit breaker enabled
- Container Insights for enhanced monitoring
- Graceful shutdown handling (SIGTERM/SIGINT)

**Terraform**
- Infrastructure as Code
- Separate state per environment
- Modular design for reusability

**AWS IAM (OIDC)**
- No long-lived AWS credentials

**CloudWatch**
- Environment-specific log groups
- Automated alarms (CPU, memory, health, response time)
- SNS integration for notifications

**Slack Integration**
- Real-time alarm notifications via AWS Chatbot
- Environment-specific channels

## 🧭 Deployment Flow

1. Code is pushed to main
2. CI builds a Docker image and pushes it to ECR
3. Image is tagged with the commit SHA
4. ECS dev deploys automatically
5. Staging promotion is triggered manually
6. Production promotion requires approval
7. ECS rolls back automatically if health checks fail
8. Each promotion generates a release record artifact

## 🔐 Security Model

- GitHub Actions authenticates to AWS using OIDC
- Each environment has its own IAM role
- No static AWS credentials
- Production secrets are protected by approval gates

## 🔁 Automatic Rollback

Each ECS service is configured with:

- Deployment circuit breaker
- ALB health checks
- Grace period for startup

If a new deployment fails:

- ECS automatically rolls back to the last healthy task definition
- CI detects the rollback and marks the deployment as failed

## 📜 Promotion History

Every deployment writes a JSON promotion record and uploads it as a GitHub Actions artifact:

```json
{
  "timestamp_utc": "2025-01-02T14:32:01Z",
  "environment": "production",
  "digest": "sha256:...",
  "image_uri": "repo@sha256:...",
  "status": "success",
  "run_id": 123456
}
```

This provides:

- traceability
- audit history
- easy rollback reference

## 📂 Repository Structure

```
.github/workflows/
  reusable-deploy-ecs.yml    # Reusable deployment workflow
  dev.yml                    # Dev environment CI/CD
  promote-staging.yml        # Staging promotion workflow
  promote-production.yml     # Production promotion workflow
  reuseable-build.yml        # Reusable build workflow with security scanning
  ci.yml                     # CI checks (test, security audit)

app/
  ecs-taskdef.dev.json       # Dev task definition
  ecs-taskdef.staging.json   # Staging task definition
  ecs-taskdef.production.json # Production task definition
  Dockerfile                 # Multi-stage optimized build
  .dockerignore              # Docker build exclusions
  src/                       # Application source code
  tests/                     # Jest test suite
  jest.config.js             # Jest configuration
  jest.setup.js              # Jest test environment setup

infra/
  bootstrap/
    bootstrap-oidc/          # OIDC provider setup
    us-east-1/               # State bucket
  modules/
    ecr/                     # ECR repository module
    ecs-fargate-service/     # ECS service + ALB + CloudWatch alarms
    github-oidc-role/        # IAM OIDC role module
    sns-topic/               # SNS topic with KMS encryption
  envs/
    dev/                     # Dev environment config
    staging/                 # Staging environment config
    prod/                    # Production environment config

README.md
```

## 🧪 Local Development

Run the application locally without Docker:

```bash
cd app
npm install
npm test
npm run dev
```

Service starts at:

```
http://localhost:3000
```

Endpoints:

- `/` — service response
- `/health` — ECS / ALB health check

## 🐳 Docker Build (Local)

Build and run the same container used in CI/CD:

```bash
docker build -t envpromote-ecs:local ./app
docker run -p 3000:3000 envpromote-ecs:local
```

Container features:
- Multi-stage build for optimized image size
- Runs as non-root user for security
- Graceful shutdown handling

## 🧪 Testing

Run the test suite with Jest:

```bash
cd app
npm test              # Run all tests
npm run test:watch    # Watch mode for development
npm run test:coverage # Generate coverage report
```

All tests run in CI before deployment.

## 🔒 Security Features

**Container Security**
- Multi-stage Docker builds
- Non-root container user
- Vulnerability scanning with Trivy in CI/CD
- Regular npm security audits

**Infrastructure Security**
- OIDC authentication (no long-lived credentials)
- KMS encryption for SNS topics
- State locking to prevent concurrent modifications
- IAM least-privilege policies

**Monitoring & Alerting**
- CloudWatch alarms for critical metrics
- Real-time Slack notifications via AWS Chatbot
- Container Insights for enhanced observability
- Automatic health checks and rollback

## 📊 CloudWatch Alarms

Each environment includes the following alarms:

- **High CPU Utilization** — triggers when CPU > 80%
- **High Memory Utilization** — triggers when memory > 80%
- **Unhealthy Target Count** — triggers when targets are unhealthy
- **Low Running Task Count** — triggers when tasks < desired count
- **High Response Time** — triggers when response time > 2 seconds

All alarms send notifications to environment-specific SNS topics, which can be routed to Slack via AWS Chatbot.

## 🧠 Key Takeaways

- CI should build artifacts; CD should promote them
- Image digests eliminate environment drift
- Production deployments should require intent and approval
- Rollback must be automatic, not manual
- Reusable workflows scale better than copy-paste pipelines
- Security scanning and testing should be built into the pipeline
- Monitoring and alerting are critical for production readiness
- Infrastructure as Code enables reproducibility and consistency

## 🚀 Why This Matters

This project demonstrates real-world DevOps practices:

- **Promotion-based delivery** — build once, deploy everywhere
- **Safe production releases** — automated testing, rollback, and approvals
- **Auditability** — promotion history and deployment records
- **Cloud-native security** — OIDC, encryption, least-privilege IAM
- **Infrastructure as Code** — reproducible, version-controlled infrastructure
- **Observability** — comprehensive monitoring, alerting, and logging
- **Container best practices** — multi-stage builds, security scanning, graceful shutdown

## 📚 Additional Documentation

- [Infrastructure Setup Guide](infra/README.md) — Terraform deployment instructions
- [GitHub Actions Workflows](.github/workflows/) — CI/CD pipeline configuration