terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  required_version = ">= 1.0"

  backend "pg" {
    # Configuration will be provided via environment variables
    # See README.md for setup instructions
  }
}

provider "aws" {
  profile = "personal"
  region = var.aws_region
}