output "id" {
  value       = aws_cloudfront_distribution.default.id
  description = "ID of the CloudFront distribution"
}

output "arn" {
  value       = aws_cloudfront_distribution.default.arn
  description = "ARN of the CloudFront distribution"
}

output "application_fqdn" {
  value       = aws_route53_record.cloudfront[0].name
  description = "Custom FQDN pointing to the distributed application"
}

output "distribution_fqdn" {
  value       = aws_cloudfront_distribution.default.domain_name
  description = "FQDN pointing to the distribution"
}

output "etag" {
  value       = aws_cloudfront_distribution.default.etag
  description = "Current version of the distribution's information"
}

output "bucket_arn" {
  value       = module.origin_bucket.arn
  description = "ARN of the origin bucket"
}

output "bucket_name" {
  value       = module.origin_bucket.name
  description = "Name of the origin bucket"
}

output "status" {
  value       = aws_cloudfront_distribution.default.status
  description = "Current status of the distribution"
}
