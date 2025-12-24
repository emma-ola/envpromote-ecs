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
