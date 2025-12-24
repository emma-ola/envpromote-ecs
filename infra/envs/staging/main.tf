locals {
  tags = {
    project     = "envpromote-ecs"
    environment = "staging"
    managed_by  = "terraform"
  }
}

# Reuse the same ECR repo created in dev (promotion means one repo, one build)
data "aws_ecr_repository" "app" {
  name = "envpromote-ecs"
}

module "ecs_app" {
  source      = "../../modules/ecs-fargate-service"
  name        = "envpromote-ecs"
  environment = "staging"
  image = "${data.aws_ecr_repository.app.repository_url}:latest"
  desired_count = 1
  cpu           = 256
  memory        = 512
  tags = local.tags
}

module "github_oidc_role" {
  source = "../../modules/github-oidc-role"
  github_owner       = var.github_owner
  github_repo        = var.github_repo
  github_environment = "staging"
  role_name          = "envpromote-gha-staging"
  ecr_repository_arn = data.aws_ecr_repository.app.arn
  tags = local.tags
}

# noinspection HttpUrlsUsage
output "staging_alb_url" {
  value = "http://${module.ecs_app.alb_dns_name}"
}

output "staging_ecs_cluster_name" {
  value = module.ecs_app.ecs_cluster_name
}

output "staging_ecs_service_name" {
  value = module.ecs_app.ecs_service_name
}

output "staging_task_execution_role_arn" {
  value = module.ecs_app.task_execution_role_arn
}

output "staging_github_actions_role_arn" {
  value = module.github_oidc_role.role_arn
}

output "ecr_repository_url" {
  value = data.aws_ecr_repository.app.repository_url
}
