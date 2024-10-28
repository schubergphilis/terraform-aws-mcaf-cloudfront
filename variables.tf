variable "name" {
  type        = string
  description = "The name of the CloudFront distribution"
}

variable "additional_redirect_uris" {
  type        = list(string)
  default     = null
  description = "Additional login redirect URLs"
}

variable "aliases" {
  type        = list(string)
  default     = []
  description = "Extra CNAMEs (alternate domain names), if any, for this distribution"
}

variable "allowed_methods" {
  type        = list(string)
  default     = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
  description = "Controls which HTTP methods CloudFront processes and forwards"
}

variable "application_logo" {
  type        = string
  default     = null
  description = "Relative path to the application logo image"
}

variable "authentication" {
  type        = bool
  default     = false
  description = "Whether to protect the cloudfront distribution behind an Okta application"
}

variable "bucket_lifecycle_rule" {
  type        = any
  default     = []
  description = "List of maps containing lifecycle management configuration settings for this bucket"
}

variable "bucket_policy" {
  type        = string
  default     = null
  description = "The bucket policy to merge with the Cloudfront permissions"
}

variable "block_public_acls" {
  type        = bool
  default     = true
  description = "Whether Amazon S3 should block public ACLs for this bucket"
}

variable "block_public_policy" {
  type        = bool
  default     = true
  description = "Whether Amazon S3 should block public bucket policies for this bucket"
}

variable "cached_methods" {
  type        = list(string)
  default     = ["GET", "HEAD"]
  description = "Controls whether CloudFront caches the response to requests"
}

variable "certificate_arn" {
  type        = string
  default     = null
  description = "The ARN of the AWS Certificate Manager certificate that you wish to use with this distribution"
}

variable "comment" {
  type        = string
  default     = null
  description = "Any comments you want to include about the distribution"
}

variable "compress" {
  type        = bool
  default     = false
  description = "Whether you want CloudFront to automatically compress content for web requests"
}

variable "cookie_domain" {
  type        = string
  default     = null
  description = "The domain to set the authentication cookie on"
}

variable "cors_allowed_headers" {
  type        = list(string)
  default     = ["*"]
  description = "Specifies which headers are allowed"
}

variable "cors_allowed_methods" {
  type        = list(string)
  default     = ["GET"]
  description = "Specifies which methods are allowed"
}

variable "cors_allowed_origins" {
  type        = list(string)
  default     = []
  description = "Specifies which origins are allowed"
}

variable "cors_expose_headers" {
  type        = list(string)
  default     = ["ETag"]
  description = "Specifies expose header in the response"
}

variable "cors_max_age_seconds" {
  type        = number
  default     = 3600
  description = "Specifies time (in seconds) the browser can cache the response for a preflight request"
}

variable "custom_error_response" {
  type = list(object({
    error_caching_min_ttl = string
    error_code            = string
    response_code         = string
    response_page_path    = string
  }))
  default     = []
  description = "List of one or more custom error response elements"
}

variable "default_root_object" {
  type        = string
  default     = "index.html"
  description = "The object that you want CloudFront to return"
}

variable "default_ttl" {
  type        = number
  default     = 3600
  description = "Default amount of time (in seconds) that an object is in a CloudFront cache"
}

variable "deployment_arn" {
  type        = string
  default     = null
  description = "A resource ARN that can be used to deploy content to the origin bucket"
}

variable "enabled" {
  type        = bool
  default     = true
  description = "Whether the distribution is enabled to accept requests for content"
}

variable "force_destroy" {
  type        = bool
  default     = false
  description = "A boolean indicating all resources (and their data) should be deleted on destroy"
}

variable "forward_cookies" {
  type        = string
  default     = "none"
  description = "Specifies whether you want CloudFront to forward cookies"
}

variable "forward_headers" {
  type        = list(string)
  default     = ["Access-Control-Request-Headers", "Access-Control-Request-Method", "Origin"]
  description = "Specifies the headers you want CloudFront to vary upon for this cache behavior"
}

variable "forward_query_strings" {
  type        = bool
  default     = false
  description = "Specifies whether you want CloudFront to forward query strings "
}

variable "geo_restriction_type" {
  type        = string
  default     = "none"
  description = "The method that you want to use to restrict distribution of your content by country"
}

variable "geo_restriction_locations" {
  type        = list(string)
  default     = null
  description = "The country codes for which you want CloudFront to whitelist or blacklist your content"
}

variable "hide_ios" {
  type        = bool
  default     = false
  description = "Do not display the Okta application icon to users on mobile app"
}

variable "hide_web" {
  type        = bool
  default     = false
  description = "Do not display the Okta application icon to users"
}

variable "ignore_public_acls" {
  type        = bool
  default     = true
  description = "Whether Amazon S3 should ignore public ACLs for this bucket"
}

variable "ipv6_enabled" {
  type        = bool
  default     = false
  description = "Whether IPv6 is enabled for the distribution"
}

variable "lambda_function_association" {
  type = list(object({
    event_type   = string
    include_body = bool
    lambda_arn   = string
  }))
  default     = []
  description = "A config block that triggers a lambda function with specific actions"
}

variable "logging" {
  type        = bool
  default     = true
  description = "Enables logging for this distribution"
}

variable "login_uri_path" {
  type        = string
  default     = null
  description = "Optional path to the login URL"
}

variable "minimum_protocol_version" {
  type        = string
  default     = "TLSv1.2_2018"
  description = "The minimum version of the SSL protocol that you want CloudFront to use for HTTPS connections"
}

variable "max_ttl" {
  type        = number
  default     = 86400
  description = "Maximum amount of time (in seconds) that an object is in a CloudFront cache"
}

variable "min_ttl" {
  type        = number
  default     = 0
  description = "Minimum amount of time that you want objects to stay in CloudFront caches"
}

variable "okta_app_name" {
  type        = string
  default     = null
  description = "The Okta OIDC application name"
}

variable "okta_org_name" {
  type        = string
  default     = null
  description = "The Okta organization for the OIDC application"
}

variable "okta_groups" {
  type        = list(string)
  default     = []
  description = "The default groups assigned to the Okta OIDC application"
}

variable "okta_spa" {
  type        = bool
  default     = false
  description = "Set to true if this is a single page web application"
}

variable "origin_path" {
  type        = string
  default     = ""
  description = "A path that CloudFront uses to request your content from a specific directory"
}

variable "price_class" {
  type        = string
  default     = "PriceClass_100"
  description = "Price class for this distribution"
}

variable "redirect_uri_path" {
  type        = string
  default     = "_callback"
  description = "Path to the login redirect URL"
}

variable "restrict_public_buckets" {
  type        = bool
  default     = true
  description = "Whether Amazon S3 should restrict public bucket policies for this bucket"
}

variable "subdomain" {
  type        = string
  description = "A DNS subdomain for this distribution"
}

variable "use_regional_endpoint" {
  type        = bool
  default     = false
  description = "Whether to use a regional instead of the global endpoint address"
}

variable "viewer_protocol_policy" {
  type        = string
  default     = "redirect-to-https"
  description = "Use this element to specify the protocol that users can use to access the files"
}

variable "wait_for_deployment" {
  type        = bool
  default     = true
  description = "Whether to wait for the deployment of the CloudFront Distribution to be complete"
}

variable "zone_id" {
  type        = string
  description = "ID of the Route53 zone in which to create the subdomain record"
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to all resources"
}
