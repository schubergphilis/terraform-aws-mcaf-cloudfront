resource "aws_cloudwatch_log_delivery_source" "access_logs" {
  count = var.logging != null ? 1 : 0

  region       = local.global_region
  name         = var.name
  log_type     = "ACCESS_LOGS"
  resource_arn = aws_cloudfront_distribution.default.arn
  tags         = var.tags
}

resource "aws_cloudwatch_log_delivery_destination" "access_logs" {
  count = var.logging != null ? 1 : 0

  region        = local.global_region
  name          = "${var.name}-s3"
  output_format = var.logging.output_format
  tags          = var.tags

  delivery_destination_configuration {
    destination_resource_arn = "arn:aws:s3:::${var.logging.target_bucket}/${var.logging.target_prefix}"
  }
}

resource "aws_cloudwatch_log_delivery" "access_logs" {
  count = var.logging != null ? 1 : 0

  region                   = local.global_region
  delivery_source_name     = aws_cloudwatch_log_delivery_source.access_logs[0].name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.access_logs[0].arn
  tags                     = var.tags
}
