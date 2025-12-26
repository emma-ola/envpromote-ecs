variable "name" {
  type = string
}

variable "environment" {
  type = string
}

variable "container_port" {
  type    = number
  default = 3000
}

variable "cpu" {
  type    = number
  default = 256
}

variable "memory" {
  type    = number
  default = 512
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "image" {
  type        = string
  description = "Container image URI (tag or digest), e.g. <repo>:<sha> or <repo>@sha256:..."
}

variable "tags" {
  type    = map(string)
  default = {}
}

# CloudWatch Alarm Variables
variable "enable_alarms" {
  type        = bool
  default     = true
  description = "Enable CloudWatch alarms for monitoring"
}

variable "alarm_sns_topic_arn" {
  type        = string
  default     = ""
  description = "SNS topic ARN for alarm notifications (optional)"
}

variable "cpu_alarm_threshold" {
  type        = number
  default     = 80
  description = "CPU utilization percentage threshold for alarm"
}

variable "memory_alarm_threshold" {
  type        = number
  default     = 80
  description = "Memory utilization percentage threshold for alarm"
}

variable "response_time_threshold" {
  type        = number
  default     = 3
  description = "Target response time threshold in seconds"
}
