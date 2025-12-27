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

# SNS Topic for CloudWatch Alarm Notifications
module "alarm_topic" {
  source       = "../../modules/sns-topic"
  name         = "envpromote-ecs-alarms-dev"
  display_name = "EnvPromote ECS Alarms - Dev"
  tags         = local.tags
}

module "ecs_app" {
  source = "../../modules/ecs-fargate-service"

  environment   = "dev"
  image         = "${module.ecr.repository_url}:latest"
  name          = "envpromote-ecs"
  desired_count = 1
  cpu           = 256
  memory        = 512

  # Configure CloudWatch alarms with SNS notifications
  enable_alarms       = true
  alarm_sns_topic_arn = module.alarm_topic.topic_arn

  tags = local.tags
}
