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

output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "github_actions_role_arn" {
  value = module.github_oidc_role.role_arn
}
