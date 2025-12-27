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

# SNS Topic for CloudWatch Alarm Notifications
module "alarm_topic" {
  source       = "../../modules/sns-topic"
  name         = "envpromote-ecs-alarms-production"
  display_name = "EnvPromote ECS Alarms - Production"
  tags         = local.tags
}

module "ecs_app" {
  source = "../../modules/ecs-fargate-service"

  name          = "envpromote-ecs"
  environment   = "production"
  image         = "${data.aws_ecr_repository.app.repository_url}:latest"
  desired_count = 2
  cpu           = 256
  memory        = 512

  # Configure CloudWatch alarms with SNS notifications
  enable_alarms       = true
  alarm_sns_topic_arn = module.alarm_topic.topic_arn

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
