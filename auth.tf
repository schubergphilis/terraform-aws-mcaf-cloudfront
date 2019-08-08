locals {
  redirect_uri = "https://${aws_cloudfront_distribution.default.domain_name}/_callback"
  ssm_prefix   = "/cloudfront-config/${aws_cloudfront_distribution.default.id}"
}

resource "okta_app_oauth" "default" {
  count                      = var.authentication ? 1 : 0
  label                      = var.okta_app_name
  status                     = "ACTIVE"
  type                       = "web"
  grant_types                = ["authorization_code", "implicit"]
  login_uri                  = "https://${aws_cloudfront_distribution.default.domain_name}/"
  redirect_uris              = [local.redirect_uri]
  response_types             = ["id_token", "code"]
  token_endpoint_auth_method = "client_secret_jwt"

  lifecycle {
    ignore_changes = ["users", "groups"]
  }
}

resource "tls_private_key" "default" {
  count     = var.authentication ? 1 : 0
  algorithm = "RSA"
}

resource "aws_ssm_parameter" "client_id" {
  count  = var.authentication ? 1 : 0
  name   = "${local.ssm_prefix}/client_id"
  type   = "SecureString"
  value  = okta_app_oauth.default[0].client_id
  key_id = var.kms_key_id
}

resource "aws_ssm_parameter" "client_secret" {
  count  = var.authentication ? 1 : 0
  name   = "${local.ssm_prefix}/client_secret"
  type   = "SecureString"
  value  = okta_app_oauth.default[0].client_secret
  key_id = var.kms_key_id
}

resource "aws_ssm_parameter" "okta_org_name" {
  count = var.authentication ? 1 : 0
  name  = "${local.ssm_prefix}/okta_org_name"
  type  = "String"
  value = var.okta_org_name
}

resource "aws_ssm_parameter" "private_key" {
  count  = var.authentication ? 1 : 0
  name   = "${local.ssm_prefix}/private_key"
  type   = "SecureString"
  value  = tls_private_key.default[0].private_key_pem
  key_id = var.kms_key_id
}

resource "aws_ssm_parameter" "public_key" {
  count  = var.authentication ? 1 : 0
  name   = "${local.ssm_prefix}/public_key"
  type   = "SecureString"
  value  = tls_private_key.default[0].public_key_pem
  key_id = var.kms_key_id
}

resource "aws_ssm_parameter" "redirect_uri" {
  count = var.authentication ? 1 : 0
  name  = "${local.ssm_prefix}/redirect_uri"
  type  = "String"
  value = local.redirect_uri
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
      var.kms_key_arn
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
  source   = "github.com/schubergphilis/terraform-aws-mcaf-lambda?ref=v0.1.3"
  name     = "${var.name}-authentication"
  filename = "${path.module}/auth_lambda/artifacts/index.zip"
  runtime  = "nodejs10.x"
  handler  = "index.handler"
  policy   = data.aws_iam_policy_document.authentication.json
  publish  = true
  region   = "us-east-1"
  tags     = var.tags
}
