locals {
  application_cert = local.subdomain ? aws_acm_certificate.default[0].arn : null
  certificate_arn  = var.certificate_arn != null ? var.certificate_arn : local.application_cert
  deployment_arn   = var.deployment_arn != null ? { create : null } : {}
  subdomain        = var.zone_id != null && var.subdomain != null

  application_fqdn = local.subdomain ? replace(
    "${var.subdomain}.${data.aws_route53_zone.current[0].name}", "/[.]$/", ""
  ) : null

  domain_name = var.use_regional_endpoint ? format(
    "%s.s3-%s.amazonaws.com", var.name, data.aws_region.current.name
  ) : "${var.name}%s.s3.amazonaws.com"
}

provider "aws" {
  alias = "cloudfront"
}

data "aws_region" "current" {}

data "aws_route53_zone" "current" {
  count   = local.subdomain ? 1 : 0
  zone_id = var.zone_id
}

data "aws_iam_policy_document" "origin_bucket" {
  statement {
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${var.name}"
    ]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.default.iam_arn]
    }
  }

  statement {
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "arn:aws:s3:::${var.name}/*"
    ]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.default.iam_arn]
    }
  }

  dynamic statement {
    for_each = local.deployment_arn

    content {
      actions = [
        "s3:ListBucket",
        "s3:PutObject",
        "s3:PutObjectAcl"
      ]
      resources = [
        "arn:aws:s3:::${var.name}",
        "arn:aws:s3:::${var.name}/*"
      ]
      principals {
        type        = "AWS"
        identifiers = [var.deployment_arn]
      }
    }
  }
}

module "origin_bucket" {
  source     = "github.com/schubergphilis/terraform-aws-mcaf-s3?ref=v0.1.4"
  name       = var.name
  policy     = data.aws_iam_policy_document.origin_bucket.json
  versioning = true
  tags       = var.tags

  cors_rule = {
    allowed_headers = var.cors_allowed_headers
    allowed_methods = var.cors_allowed_methods
    allowed_origins = sort(
      distinct(compact(concat(var.cors_allowed_origins, var.aliases, [local.application_fqdn]))),
    )
    expose_headers  = var.cors_expose_headers
    max_age_seconds = var.cors_max_age_seconds
  }
}

resource "aws_route53_record" "cloudfront" {
  count   = local.subdomain ? 1 : 0
  zone_id = var.zone_id
  name    = local.application_fqdn
  type    = "CNAME"
  ttl     = "5"
  records = [aws_cloudfront_distribution.default.domain_name]
}

resource "aws_acm_certificate" "default" {
  provider          = "aws.cloudfront"
  count             = local.subdomain ? 1 : 0
  domain_name       = local.application_fqdn
  validation_method = "DNS"
  tags              = var.tags
}

resource "aws_route53_record" "validation" {
  count   = local.subdomain ? 1 : 0
  zone_id = data.aws_route53_zone.current[0].zone_id
  name    = aws_acm_certificate.default[0].domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.default[0].domain_validation_options.0.resource_record_type
  ttl     = 60
  records = [aws_acm_certificate.default[0].domain_validation_options.0.resource_record_value]
}

resource "aws_acm_certificate_validation" "default" {
  provider                = "aws.cloudfront"
  count                   = local.subdomain ? 1 : 0
  certificate_arn         = aws_acm_certificate.default[0].arn
  validation_record_fqdns = [aws_route53_record.validation[0].fqdn]
}

resource "aws_cloudfront_origin_access_identity" "default" {
  comment = var.name
}

resource "aws_cloudfront_distribution" "default" {
  aliases             = distinct(compact(concat(var.aliases, [local.application_fqdn])))
  comment             = var.comment
  default_root_object = var.default_root_object
  enabled             = var.enabled
  is_ipv6_enabled     = var.ipv6_enabled
  price_class         = var.price_class
  wait_for_deployment = true
  tags                = var.tags

  origin {
    domain_name = local.domain_name
    origin_id   = var.name
    origin_path = var.origin_path

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.default.cloudfront_access_identity_path
    }
  }

  viewer_certificate {
    acm_certificate_arn            = local.certificate_arn
    ssl_support_method             = local.certificate_arn != null ? "sni-only" : null
    minimum_protocol_version       = var.minimum_protocol_version
    cloudfront_default_certificate = local.certificate_arn == null ? true : false
  }

  default_cache_behavior {
    allowed_methods  = var.allowed_methods
    cached_methods   = var.cached_methods
    target_origin_id = var.name
    compress         = var.compress

    forwarded_values {
      query_string = var.forward_query_strings
      headers      = var.forward_headers

      cookies {
        forward = var.forward_cookies
      }
    }

    viewer_protocol_policy = var.viewer_protocol_policy
    default_ttl            = var.default_ttl
    min_ttl                = var.min_ttl
    max_ttl                = var.max_ttl

    lambda_function_association {
      event_type = "viewer-request"
      lambda_arn = module.authentication.qualified_arn
    }

    dynamic "lambda_function_association" {
      for_each = var.lambda_function_association

      content {
        event_type   = lambda_function_association.value.event_type
        include_body = lookup(lambda_function_association.value, "include_body", null)
        lambda_arn   = lambda_function_association.value.lambda_arn
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction_type
      locations        = var.geo_restriction_locations
    }
  }

  dynamic "custom_error_response" {
    for_each = var.custom_error_response

    content {
      error_caching_min_ttl = lookup(custom_error_response.value, "error_caching_min_ttl", null)
      error_code            = custom_error_response.value.error_code
      response_code         = lookup(custom_error_response.value, "response_code", null)
      response_page_path    = lookup(custom_error_response.value, "response_page_path", null)
    }
  }
}
