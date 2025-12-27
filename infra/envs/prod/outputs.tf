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

output "alarm_topic_arn" {
  value       = module.alarm_topic.topic_arn
  description = "SNS topic ARN for CloudWatch alarm notifications - use this for AWS Chatbot configuration"
}
