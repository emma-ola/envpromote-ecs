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
- CI build & push
- Reusable deploy workflow
- Manual promotion workflows

**Amazon ECR**
- Single repository
- Immutable image digests

**Amazon ECS (Fargate)**
- Separate clusters/services per environment
- Deployment circuit breaker enabled

**Terraform**
- Infrastructure as Code
- Separate state per environment

**AWS IAM (OIDC)**
- No long-lived AWS credentials

**CloudWatch Logs**
- Environment-specific log groups

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
  reusable-deploy-ecs.yml
  dev.yml
  promote-staging.yml
  promote-production.yml
  reuseable-build.yml
  ci.yml

app/
  ecs-taskdef.dev.json
  ecs-taskdef.staging.json
  ecs-taskdef.production.json
  Dockerfile
  src/
  tests/

infra/
  bootstrap/
  modules/
  envs/
    dev/
    staging/
    production/

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

## 🧠 Key Takeaways

- CI should build artifacts; CD should promote them
- Image digests eliminate environment drift
- Production deployments should require intent and approval
- Rollback must be automatic, not manual
- Reusable workflows scale better than copy-paste pipelines

## 🚀 Why This Matters

This project demonstrates real-world DevOps practices:

- Promotion-based delivery
- Safe production releases
- Auditability
- Cloud-native security
- Infrastructure as Code

It reflects how modern platform and DevOps teams ship software reliably at scale.