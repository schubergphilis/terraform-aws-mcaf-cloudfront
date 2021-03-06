locals {
  cookie_domain      = var.cookie_domain != null ? var.cookie_domain : local.login_domain
  create_auth_lambda = var.authentication && !var.okta_spa ? ["create"] : []
  login_domain       = aws_route53_record.cloudfront.name
  login_uri          = var.login_uri_path != null ? format("https://%s/%s", local.login_domain, trimprefix(var.login_uri_path, "/")) : "https://${local.login_domain}/"
  okta_groups        = var.authentication ? var.okta_groups : []
  redirect_uri       = "https://${local.login_domain}/${trimprefix(var.redirect_uri_path, "/")}"
  ssm_prefix         = "/cloudfront-config/${aws_cloudfront_distribution.default.id}"
}

resource "aws_kms_key" "default" {
  provider            = aws.cloudfront
  description         = "KMS key used for encrypting cloudfront SSM parameters"
  is_enabled          = true
  enable_key_rotation = false
  tags                = var.tags
}

resource "aws_kms_alias" "default" {
  provider      = aws.cloudfront
  name          = "alias/cloudfront-ssm-${aws_cloudfront_distribution.default.id}"
  target_key_id = aws_kms_key.default.key_id
}

data "aws_iam_policy_document" "authentication" {
  statement {
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      module.origin_bucket.arn
    ]
  }

  statement {
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "${module.origin_bucket.arn}${var.origin_path}/*"
    ]
  }

  statement {
    actions = [
      "kms:Decrypt"
    ]
    resources = [
      aws_kms_key.default.arn
    ]
  }

  statement {
    actions = [
      "ssm:GetParameters"
    ]
    resources = [
      "arn:aws:ssm:*:*:parameter/cloudfront-config/${aws_cloudfront_distribution.default.id}/*"
    ]
  }
}

module "authentication" {
  providers = { aws.lambda = aws.cloudfront }
  count     = length(local.create_auth_lambda)
  source    = "github.com/schubergphilis/terraform-aws-mcaf-lambda?ref=v0.1.24"
  name      = "${var.name}-authentication"
  filename  = "${path.module}/auth_lambda/artifacts/index.zip"
  runtime   = "nodejs10.x"
  handler   = "index.handler"
  policy    = data.aws_iam_policy_document.authentication.json
  publish   = true
  tags      = var.tags
}

resource "okta_app_oauth" "default" {
  count                      = var.authentication ? 1 : 0
  label                      = var.okta_app_name
  status                     = "ACTIVE"
  type                       = var.okta_spa ? "browser" : "web"
  consent_method             = var.okta_spa ? "REQUIRED" : "TRUSTED"
  grant_types                = ["authorization_code", "implicit"]
  hide_ios                   = var.hide_ios
  hide_web                   = var.hide_web
  login_uri                  = local.login_uri
  login_mode                 = "SPEC"
  redirect_uris              = concat([local.redirect_uri], coalesce(var.additional_redirect_uris, []))
  response_types             = ["token", "id_token", "code"]
  token_endpoint_auth_method = var.okta_spa ? "none" : "client_secret_jwt"

  lifecycle {
    ignore_changes = [users, groups, consent_method]
  }
}

resource "okta_app_group_assignment" "default" {
  for_each = toset(local.okta_groups)

  app_id   = okta_app_oauth.default[0].id
  group_id = each.value
  priority = 1

  lifecycle {
    ignore_changes = [priority]
  }
}

resource "tls_private_key" "default" {
  count     = length(local.create_auth_lambda)
  algorithm = "RSA"
}

resource "aws_ssm_parameter" "client_id" {
  provider = aws.cloudfront
  count    = length(local.create_auth_lambda)
  name     = "${local.ssm_prefix}/client_id"
  type     = "SecureString"
  value    = okta_app_oauth.default[0].client_id
  key_id   = aws_kms_key.default.id
  tags     = var.tags
}

resource "aws_ssm_parameter" "client_secret" {
  provider = aws.cloudfront
  count    = length(local.create_auth_lambda)
  name     = "${local.ssm_prefix}/client_secret"
  type     = "SecureString"
  value    = okta_app_oauth.default[0].client_secret
  key_id   = aws_kms_key.default.id
  tags     = var.tags
}

resource "aws_ssm_parameter" "okta_org_name" {
  provider = aws.cloudfront
  count    = length(local.create_auth_lambda)
  name     = "${local.ssm_prefix}/okta_org_name"
  type     = "String"
  value    = var.okta_org_name
  tags     = var.tags
}

resource "aws_ssm_parameter" "private_key" {
  provider = aws.cloudfront
  count    = length(local.create_auth_lambda)
  name     = "${local.ssm_prefix}/private_key"
  type     = "SecureString"
  value    = tls_private_key.default[0].private_key_pem
  key_id   = aws_kms_key.default.id
  tags     = var.tags
}

resource "aws_ssm_parameter" "public_key" {
  provider = aws.cloudfront
  count    = length(local.create_auth_lambda)
  name     = "${local.ssm_prefix}/public_key"
  type     = "SecureString"
  value    = tls_private_key.default[0].public_key_pem
  key_id   = aws_kms_key.default.id
  tags     = var.tags
}

resource "aws_ssm_parameter" "redirect_uri" {
  provider = aws.cloudfront
  count    = length(local.create_auth_lambda)
  name     = "${local.ssm_prefix}/redirect_uri"
  type     = "String"
  value    = local.redirect_uri
  tags     = var.tags
}

resource "aws_ssm_parameter" "cookie_domain" {
  provider = aws.cloudfront
  count    = length(local.create_auth_lambda)
  name     = "${local.ssm_prefix}/cookie_domain"
  type     = "String"
  value    = local.cookie_domain
  tags     = var.tags
}
