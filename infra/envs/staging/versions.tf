terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "envpromote-tfstate-tomideo"
    key            = "envpromote/staging/terraform.tfstate"
    region         = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
