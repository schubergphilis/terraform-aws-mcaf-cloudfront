provider "aws" {
  region = "eu-west-1"
}

module "static_website" {
  source = "../.."

  name = "mystatic-website"

  subdomain = "mystaticwebsite"
  zone_id   = module.zone_services.route53_zone_id
}
