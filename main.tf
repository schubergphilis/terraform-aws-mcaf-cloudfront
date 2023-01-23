locals {
  application_fqdn  = var.subdomain != null ? replace("${var.subdomain}.${data.aws_route53_zone.current.name}", "/[.]$/", "") : null
  certificate_arn   = var.certificate_arn != null ? var.certificate_arn : aws_acm_certificate.default.0.arn
  certificate_count = var.certificate_arn == null ? 1 : 0
  deployment_arn    = var.deployment_arn != null ? { create : null } : {}

  endpoint_type = var.endpoint_type

  domain_name = var.use_regional_endpoint ? format(
    "%s.%s-%s.amazonaws.com", var.name, var.endpoint_type, data.aws_region.current.name
  ) : format("${var.name}.%s.amazonaws.com", var.endpoint_type)
}

data "aws_region" "current" {}

data "aws_route53_zone" "current" {
  zone_id = var.zone_id
}

resource "aws_route53_record" "cloudfront" {
  count   = local.application_fqdn != null ? 1 : 0
  zone_id = var.zone_id
  name    = local.application_fqdn
  type    = "CNAME"
  ttl     = "5"
  records = [aws_cloudfront_distribution.default.domain_name]
}

resource "aws_acm_certificate" "default" {
  count             = local.certificate_count
  provider          = aws.cloudfront
  domain_name       = local.application_fqdn
  validation_method = "DNS"
  tags              = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "validation" {
  count   = local.certificate_count
  name    = aws_acm_certificate.default[count.index].domain_validation_options.*.resource_record_name[0]
  records = [aws_acm_certificate.default[count.index].domain_validation_options.*.resource_record_value[0]]
  type    = aws_acm_certificate.default[count.index].domain_validation_options.*.resource_record_type[0]
  zone_id = data.aws_route53_zone.current.zone_id
  ttl     = 60
}

resource "aws_acm_certificate_validation" "default" {
  count                   = local.certificate_count
  provider                = aws.cloudfront
  certificate_arn         = aws_acm_certificate.default[count.index].arn
  validation_record_fqdns = [aws_route53_record.validation[count.index].fqdn]
}

resource "aws_cloudfront_origin_access_identity" "default" {
  count   = var.endpoint_type == "s3" ? 1 : 0
  comment = var.name
}

resource "aws_cloudfront_distribution" "default" {
  aliases             = local.application_fqdn != null ? distinct(compact(concat(var.aliases, [local.application_fqdn]))) : null
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

    dynamic "s3_origin_config" {
      for_each = var.endpoint_type == "s3" ? { enable = true } : {}
      content {
        origin_access_identity = aws_cloudfront_origin_access_identity.default.cloudfront_access_identity_path
      }
    }

    dynamic "custom_header" {
      for_each = var.custom_header

      content {
        name  = custom_header.value["name"]
        value = custom_header.value["value"]
      }
    }

    dynamic "custom_origin_config" {
      for_each = var.custom_origin_config
      content {
        http_port              = custom_origin_config.value["http_port"]
        https_port             = custom_origin_config.value["https_port"]
        origin_protocol_policy = custom_origin_config.value["origin_protocol_policy"]
        origin_ssl_protocols   = custom_origin_config.value["origin_ssl_protocols"]
      }
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
