provider "aws" {
  region = "eu-west-1"
}

provider "aws" {
  alias  = "cloudfront"
  region = "us-west-1"
}

data "aws_route53_zone" "selected" {
  name         = "test.com."
  private_zone = true
}

module "static_website" {
  providers = {
    aws            = aws
    aws.cloudfront = aws.cloudfront
  }

  source = "../.."

  name = "mystatic-website"

  subdomain      = "mystaticwebsite"
  zone_id        = data.aws_route53_zone.selected.zone_id
  authentication = false
}
