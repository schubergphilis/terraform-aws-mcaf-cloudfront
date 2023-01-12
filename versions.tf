terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.cloudfront]
      version               = ">= 4.0.0"
    }
    okta = {
      source  = "okta/okta"
      version = ">= 3.38.0"
    }
    tls = {
      source = "hashicorp/tls"
    }
  }
  required_version = ">= 0.13"
}
