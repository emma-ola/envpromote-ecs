variable "name" {
  type        = string
  description = "SNS topic name"
}

variable "display_name" {
  type        = string
  default     = ""
  description = "Display name for SNS topic (shown in notifications)"
}

variable "enable_encryption" {
  type        = bool
  default     = true
  description = "Enable encryption at rest using AWS managed key"
}

variable "email_address" {
  type        = string
  default     = ""
  description = "Optional email address for backup notifications"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the SNS topic"
}
