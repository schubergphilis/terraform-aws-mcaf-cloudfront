terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.cloudfront]
      version               = ">= 5.0.0"
    }
    okta = {
      source  = "okta/okta"
      version = ">= 4.0.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~ 4.1"
    }
  }
}
