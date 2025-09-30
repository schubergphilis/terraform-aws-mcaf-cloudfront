terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    okta = {
      source  = "okta/okta"
      version = ">= 6.0.0"
    }
  }
}
