locals {
  application_fqdn  = replace("${var.subdomain}.${data.aws_route53_zone.current.name}", "/[.]$/", "")
  certificate_arn   = var.certificate_arn != null ? var.certificate_arn : aws_acm_certificate.default[0].arn
  certificate_count = var.certificate_arn == null ? 1 : 0
  deployment_arn    = var.deployment_arn != null ? { create : null } : {}

  domain_name = var.use_regional_endpoint ? format(
    "%s.s3-%s.amazonaws.com", var.name, data.aws_region.current.name
  ) : "${var.name}.s3.amazonaws.com"
}

data "aws_region" "current" {
  region = var.region
}

data "aws_route53_zone" "current" {
  zone_id = var.zone_id
}

resource "aws_route53_record" "cloudfront" {
  zone_id = var.zone_id
  name    = local.application_fqdn
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.default.domain_name
    zone_id                = aws_cloudfront_distribution.default.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_acm_certificate" "default" {
  count = local.certificate_count

  region            = local.global_region
  domain_name       = local.application_fqdn
  validation_method = "DNS"
  tags              = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in flatten([
      for c in aws_acm_certificate.default : c.domain_validation_options
      ]) : "create" => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  name    = each.value.name
  records = [each.value.record]
  ttl     = 60
  type    = each.value.type
  zone_id = data.aws_route53_zone.current.zone_id
}

resource "aws_acm_certificate_validation" "default" {
  count = local.certificate_count

  region                  = local.global_region
  certificate_arn         = aws_acm_certificate.default[count.index].arn
  validation_record_fqdns = [aws_route53_record.validation["create"].fqdn]
}

resource "aws_cloudfront_origin_access_identity" "default" {
  comment = var.name
}

resource "aws_cloudfront_distribution" "default" {
  #checkov:skip=CKV_AWS_374: "Ensure AWS CloudFront web distribution has geo restriction enabled"
  #checkov:skip=CKV_AWS_310: "Ensure CloudFront distributions should have origin failover configured"
  #checkov:skip=CKV_AWS_68: "CloudFront Distribution should have WAF enabled"
  #checkov:skip=CKV_AWS_86: "Ensure CloudFront distribution has Access Logging enabled"
  #checkov:skip=CKV2_AWS_47: "Ensure AWS CloudFront attached WAFv2 WebACL is configured with AMR for Log4j Vulnerability"
  #checkov:skip=CKV2_AWS_32: "Ensure CloudFront distribution has a response headers policy attached"
  aliases             = distinct(compact(concat(var.aliases, [local.application_fqdn])))
  comment             = var.comment
  default_root_object = var.default_root_object
  enabled             = var.enabled
  is_ipv6_enabled     = var.ipv6_enabled
  price_class         = var.price_class
  wait_for_deployment = var.wait_for_deployment
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

    dynamic "lambda_function_association" {
      for_each = local.create_auth_lambda

      content {
        event_type = "viewer-request"
        lambda_arn = module.authentication[0].qualified_arn
      }
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

  depends_on = [aws_acm_certificate_validation.default]
}
