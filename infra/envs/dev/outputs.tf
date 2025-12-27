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

output "alarm_topic_arn" {
  value       = module.alarm_topic.topic_arn
  description = "SNS topic ARN for CloudWatch alarm notifications - use this for AWS Chatbot configuration"
}
