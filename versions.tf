terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    okta = {
      source = "oktadeveloper/okta"
    }
    tls = {
      source = "hashicorp/tls"
    }
  }
  required_version = ">= 0.13"
}
