variable "github_owner" {
  type = string
}

variable "github_repo" {
  type = string
}

variable "allowed_branch" {
  type    = string
  default = "main"
}

variable "github_environment" {
  type        = string
  description = "GitHub environment name (dev/staging/production)"
}

variable "role_name" {
  type = string
}

variable "ecr_repository_arn" {
  type        = string
  description = "ARN of the ECR repository this role can push to"
}

variable "tags" {
  type    = map(string)
  default = {}
}
