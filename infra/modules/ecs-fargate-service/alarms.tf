# CloudWatch Alarms for ECS Service Monitoring

# CPU Utilization Alarm
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  count               = var.enable_alarms ? 1 : 0
  alarm_name          = "${var.name}-${var.environment}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = var.cpu_alarm_threshold
  alarm_description   = "ECS service CPU utilization is above ${var.cpu_alarm_threshold}% for 10 minutes"
  alarm_actions       = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []
  treat_missing_data  = "missing"

  dimensions = {
    ServiceName = aws_ecs_service.this.name
    ClusterName = aws_ecs_cluster.this.name
  }

  tags = var.tags
}

# Memory Utilization Alarm
resource "aws_cloudwatch_metric_alarm" "memory_high" {
  count               = var.enable_alarms ? 1 : 0
  alarm_name          = "${var.name}-${var.environment}-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = var.memory_alarm_threshold
  alarm_description   = "ECS service memory utilization is above ${var.memory_alarm_threshold}% for 10 minutes"
  alarm_actions       = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []
  treat_missing_data  = "missing"

  dimensions = {
    ServiceName = aws_ecs_service.this.name
    ClusterName = aws_ecs_cluster.this.name
  }

  tags = var.tags
}

# Unhealthy Target Alarm (ALB health checks failing)
resource "aws_cloudwatch_metric_alarm" "unhealthy_targets" {
  count               = var.enable_alarms ? 1 : 0
  alarm_name          = "${var.name}-${var.environment}-unhealthy-targets"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "ALB has unhealthy targets - ECS tasks are failing health checks"
  alarm_actions       = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []
  treat_missing_data  = "missing"

  dimensions = {
    TargetGroup  = aws_lb_target_group.this.arn_suffix
    LoadBalancer = aws_lb.this.arn_suffix
  }

  tags = var.tags
}

# Running Task Count Alarm (service degraded)
resource "aws_cloudwatch_metric_alarm" "task_count_low" {
  count               = var.enable_alarms ? 1 : 0
  alarm_name          = "${var.name}-${var.environment}-task-count-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "RunningTaskCount"
  namespace           = "ECS/ContainerInsights"
  period              = 60
  statistic           = "Minimum"
  threshold           = var.desired_count
  alarm_description   = "ECS service has fewer running tasks than desired count - service may be degraded"
  alarm_actions       = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []
  treat_missing_data  = "missing"

  dimensions = {
    ServiceName = aws_ecs_service.this.name
    ClusterName = aws_ecs_cluster.this.name
  }

  tags = var.tags
}

# Target Response Time Alarm (performance degradation)
resource "aws_cloudwatch_metric_alarm" "high_response_time" {
  count               = var.enable_alarms ? 1 : 0
  alarm_name          = "${var.name}-${var.environment}-high-response-time"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = var.response_time_threshold
  alarm_description   = "ALB target response time is above ${var.response_time_threshold}s for 2 minutes"
  alarm_actions       = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []
  treat_missing_data  = "missing"

  dimensions = {
    TargetGroup  = aws_lb_target_group.this.arn_suffix
    LoadBalancer = aws_lb.this.arn_suffix
  }

  tags = var.tags
}
