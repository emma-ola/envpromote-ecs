variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "github_owner" {
  type        = string
  description = "GitHub org/user that owns the repo"
}

variable "github_repo" {
  type        = string
  description = "GitHub repo name, e.g. envpromote-ecs"
}
