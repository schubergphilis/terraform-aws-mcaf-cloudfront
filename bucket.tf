locals {
  bucket_policy = var.bucket_policy != null ? [var.bucket_policy] : null
}

data "aws_iam_policy_document" "origin_bucket" {
  source_policy_documents = local.bucket_policy

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

  dynamic "statement" {
    for_each = local.deployment_arn

    content {
      actions = [
        "s3:ListBucket",
        "s3:PutObject",
        "s3:PutObjectAcl",
      ]
      resources = [
        "arn:aws:s3:::${var.name}",
        "arn:aws:s3:::${var.name}/*",
      ]
      principals {
        type        = "AWS"
        identifiers = [var.deployment_arn]
      }
    }
  }
}

module "origin_bucket" {
  source  = "schubergphilis/mcaf-s3/aws"
  version = "~> 1.5.2"

  name                    = var.name
  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  force_destroy           = var.force_destroy
  ignore_public_acls      = var.ignore_public_acls
  lifecycle_rule          = var.bucket_lifecycle_rule
  restrict_public_buckets = var.restrict_public_buckets
  policy                  = data.aws_iam_policy_document.origin_bucket.json
  versioning              = true
  tags                    = var.tags

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
