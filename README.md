# EnvPromote ECS

Reusable GitHub Actions CI/CD promotion pipeline for deploying containerized applications to Amazon ECS with environment gates, approvals, and immutable artifact promotion.

---

## Problem / Context

Teams were deploying to multiple environments using manual steps and environment-specific pipelines, which increased deployment risk and slowed releases.

---

## Goals

- Reduce manual steps to minimize errors and speed up deployments
- Improve safety and consistency across environments
- Add clear promotion gates to ensure quality before production
- Promote the same immutable artifact across environments to prevent drift

---

## Solution Overview

I designed a reusable CI/CD pipeline using GitHub Actions that supports environment promotion, automated checks, and clear approval gates. The same container image is built once and promoted across dev → staging → production to reduce drift and improve release confidence.

---

## Architecture (High Level)

- GitHub Actions for CI and promotion-based CD
- Amazon ECR for container images
- Amazon ECS (Fargate) for running services
- CloudWatch Logs for centralized logging
- GitHub Environments (dev, staging, production) for scoped secrets and approval gates
- AWS IAM via GitHub OIDC (no long-lived AWS keys)

---

## Implementation Details

- Reusable GitHub Actions workflows for build, test, and deploy
- Environment-specific configuration handled via inputs and GitHub Environment secrets
- Manual approvals enforced for production deployments using protected environments
- Consistent logging and status reporting across all stages

---

## Results

- Reduced manual deployment steps and human error
- Improved confidence in production releases
- Created a reusable pipeline pattern for future projects

---

## Key Takeaways

- Designed CI/CD systems with safety and promotion in mind
- Reduced manual deployment risk through automation and gates
- Built reusable pipeline patterns that scale across projects

---

## Repository Structure

.github/workflows/  — CI and promotion pipelines  
app/               — Demo containerized application  
infra/             — Terraform for AWS infrastructure  
README.md

---

## Local Development

Run the application locally without Docker:

```bash
cd app
npm install
npm test
npm run dev
```

The service will start on:

```
http://localhost:3000
```

Useful endpoints:

- `/` — basic service response
- `/health` — health check used by ECS / ALB

---

## Docker Build (Local)

Build and run the same container image used by CI/CD and ECS:

```bash
docker build -t envpromote-ecs:local ./app
docker run -p 3000:3000 envpromote-ecs:local
```
