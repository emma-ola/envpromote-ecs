locals {
  tags = {
    project     = "envpromote-ecs"
    environment = "dev"
    managed_by  = "terraform"
  }
}

module "ecr" {
  source = "../../modules/ecr"
  name   = "envpromote-ecs"
  tags   = local.tags
}

module "github_oidc_role" {
  source             = "../../modules/github-oidc-role"
  github_owner       = var.github_owner
  github_repo        = var.github_repo
  github_environment = "dev"
  role_name          = "envpromote-gha-dev"
  ecr_repository_arn = module.ecr.repository_arn
  tags               = local.tags
}

module "ecs_app" {
  source = "../../modules/ecs-fargate-service"
  environment = "dev"
  image = "${module.ecr.repository_url}:latest"
  name = "envpromote-ecs"
  desired_count = 1
  cpu = 256
  memory = 512
  tags = local.tags
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "github_actions_role_arn" {
  value = module.github_oidc_role.role_arn
}

# noinspection HttpUrlsUsage
output "dev_alb_url" {
  value = "http://${module.ecs_app.alb_dns_name}"
}

output "dev_ecs_cluster_name" {
  value = module.ecs_app.ecs_cluster_name
}

output "dev_ecs_service_name" {
  value = module.ecs_app.ecs_service_name
}

output "dev_task_execution_role_arn" {
  value = module.ecs_app.task_execution_role_arn
}
