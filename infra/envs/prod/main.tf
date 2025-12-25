locals {
  tags = {
    project     = "envpromote-ecs"
    environment = "production"
    managed_by  = "terraform"
  }
}

# Reuse the same ECR repo created originally (promotion = one repo, one build)
data "aws_ecr_repository" "app" {
  name = "envpromote-ecs"
}

module "ecs_app" {
  source      = "../../modules/ecs-fargate-service"
  name        = "envpromote-ecs"
  environment = "production"
  image = "${data.aws_ecr_repository.app.repository_url}:latest"
  desired_count = 2
  cpu           = 256
  memory        = 512
  tags = local.tags
}

module "github_oidc_role" {
  source = "../../modules/github-oidc-role"
  github_owner       = var.github_owner
  github_repo        = var.github_repo
  github_environment = "production"
  role_name          = "envpromote-gha-production"
  ecr_repository_arn = data.aws_ecr_repository.app.arn
  tags = local.tags
}

# noinspection HttpUrlsUsage
output "production_alb_url" {
  value = "http://${module.ecs_app.alb_dns_name}"
}

output "production_ecs_cluster_name" {
  value = module.ecs_app.ecs_cluster_name
}

output "production_ecs_service_name" {
  value = module.ecs_app.ecs_service_name
}

output "production_task_execution_role_arn" {
  value = module.ecs_app.task_execution_role_arn
}

output "production_github_actions_role_arn" {
  value = module.github_oidc_role.role_arn
}

output "ecr_repository_url" {
  value = data.aws_ecr_repository.app.repository_url
}
