# terraform-aws-mcaf-cloudfront

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0 |
| <a name="requirement_okta"></a> [okta](#requirement\_okta) | >= 3.36.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0.0 |
| <a name="provider_aws.cloudfront"></a> [aws.cloudfront](#provider\_aws.cloudfront) | >= 4.0.0 |
| <a name="provider_okta"></a> [okta](#provider\_okta) | >= 3.36.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_authentication"></a> [authentication](#module\_authentication) | github.com/schubergphilis/terraform-aws-mcaf-lambda | v0.3.3 |
| <a name="module_origin_bucket"></a> [origin\_bucket](#module\_origin\_bucket) | github.com/schubergphilis/terraform-aws-mcaf-s3 | v0.6.1 |

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_cloudfront_distribution.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_origin_access_identity.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_identity) | resource |
| [aws_route53_record.cloudfront](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_ssm_parameter.client_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.client_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.cookie_domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.okta_org_name](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.private_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.public_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.redirect_uri](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [okta_app_group_assignment.default](https://registry.terraform.io/providers/okta/okta/latest/docs/resources/app_group_assignment) | resource |
| [okta_app_oauth.default](https://registry.terraform.io/providers/okta/okta/latest/docs/resources/app_oauth) | resource |
| [tls_private_key.default](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [aws_iam_policy_document.authentication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.origin_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_route53_zone.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | The name of the CloudFront distribution | `string` | n/a | yes |
| <a name="input_subdomain"></a> [subdomain](#input\_subdomain) | A DNS subdomain for this distribution | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to all resources | `map(string)` | n/a | yes |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | ID of the Route53 zone in which to create the subdomain record | `string` | n/a | yes |
| <a name="input_additional_redirect_uris"></a> [additional\_redirect\_uris](#input\_additional\_redirect\_uris) | Additional login redirect URLs | `list(string)` | `null` | no |
| <a name="input_aliases"></a> [aliases](#input\_aliases) | Extra CNAMEs (alternate domain names), if any, for this distribution | `list(string)` | `[]` | no |
| <a name="input_allowed_methods"></a> [allowed\_methods](#input\_allowed\_methods) | Controls which HTTP methods CloudFront processes and forwards | `list(string)` | <pre>[<br>  "DELETE",<br>  "GET",<br>  "HEAD",<br>  "OPTIONS",<br>  "PATCH",<br>  "POST",<br>  "PUT"<br>]</pre> | no |
| <a name="input_application_logo"></a> [application\_logo](#input\_application\_logo) | Relative path to the application logo image | `string` | `null` | no |
| <a name="input_authentication"></a> [authentication](#input\_authentication) | Whether to protect the cloudfront distribution behind an Okta application | `bool` | `false` | no |
| <a name="input_block_public_acls"></a> [block\_public\_acls](#input\_block\_public\_acls) | Whether Amazon S3 should block public ACLs for this bucket | `bool` | `true` | no |
| <a name="input_block_public_policy"></a> [block\_public\_policy](#input\_block\_public\_policy) | Whether Amazon S3 should block public bucket policies for this bucket | `bool` | `true` | no |
| <a name="input_bucket_policy"></a> [bucket\_policy](#input\_bucket\_policy) | The bucket policy to merge with the Cloudfront permissions | `string` | `null` | no |
| <a name="input_cached_methods"></a> [cached\_methods](#input\_cached\_methods) | Controls whether CloudFront caches the response to requests | `list(string)` | <pre>[<br>  "GET",<br>  "HEAD"<br>]</pre> | no |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | The ARN of the AWS Certificate Manager certificate that you wish to use with this distribution | `string` | `null` | no |
| <a name="input_comment"></a> [comment](#input\_comment) | Any comments you want to include about the distribution | `string` | `null` | no |
| <a name="input_compress"></a> [compress](#input\_compress) | Whether you want CloudFront to automatically compress content for web requests | `bool` | `false` | no |
| <a name="input_cookie_domain"></a> [cookie\_domain](#input\_cookie\_domain) | The domain to set the authentication cookie on | `string` | `null` | no |
| <a name="input_cors_allowed_headers"></a> [cors\_allowed\_headers](#input\_cors\_allowed\_headers) | Specifies which headers are allowed | `list(string)` | <pre>[<br>  "*"<br>]</pre> | no |
| <a name="input_cors_allowed_methods"></a> [cors\_allowed\_methods](#input\_cors\_allowed\_methods) | Specifies which methods are allowed | `list(string)` | <pre>[<br>  "GET"<br>]</pre> | no |
| <a name="input_cors_allowed_origins"></a> [cors\_allowed\_origins](#input\_cors\_allowed\_origins) | Specifies which origins are allowed | `list(string)` | `[]` | no |
| <a name="input_cors_expose_headers"></a> [cors\_expose\_headers](#input\_cors\_expose\_headers) | Specifies expose header in the response | `list(string)` | <pre>[<br>  "ETag"<br>]</pre> | no |
| <a name="input_cors_max_age_seconds"></a> [cors\_max\_age\_seconds](#input\_cors\_max\_age\_seconds) | Specifies time (in seconds) the browser can cache the response for a preflight request | `number` | `3600` | no |
| <a name="input_custom_error_response"></a> [custom\_error\_response](#input\_custom\_error\_response) | List of one or more custom error response elements | <pre>list(object({<br>    error_caching_min_ttl = string<br>    error_code            = string<br>    response_code         = string<br>    response_page_path    = string<br>  }))</pre> | `[]` | no |
| <a name="input_default_root_object"></a> [default\_root\_object](#input\_default\_root\_object) | The object that you want CloudFront to return | `string` | `"index.html"` | no |
| <a name="input_default_ttl"></a> [default\_ttl](#input\_default\_ttl) | Default amount of time (in seconds) that an object is in a CloudFront cache | `number` | `3600` | no |
| <a name="input_deployment_arn"></a> [deployment\_arn](#input\_deployment\_arn) | A resource ARN that can be used to deploy content to the origin bucket | `string` | `null` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Whether the distribution is enabled to accept requests for content | `bool` | `true` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | A boolean indicating all resources (and their data) should be deleted on destroy | `bool` | `false` | no |
| <a name="input_forward_cookies"></a> [forward\_cookies](#input\_forward\_cookies) | Specifies whether you want CloudFront to forward cookies | `string` | `"none"` | no |
| <a name="input_forward_headers"></a> [forward\_headers](#input\_forward\_headers) | Specifies the headers you want CloudFront to vary upon for this cache behavior | `list(string)` | <pre>[<br>  "Access-Control-Request-Headers",<br>  "Access-Control-Request-Method",<br>  "Origin"<br>]</pre> | no |
| <a name="input_forward_query_strings"></a> [forward\_query\_strings](#input\_forward\_query\_strings) | Specifies whether you want CloudFront to forward query strings | `bool` | `false` | no |
| <a name="input_geo_restriction_locations"></a> [geo\_restriction\_locations](#input\_geo\_restriction\_locations) | The country codes for which you want CloudFront to whitelist or blacklist your content | `list(string)` | `null` | no |
| <a name="input_geo_restriction_type"></a> [geo\_restriction\_type](#input\_geo\_restriction\_type) | The method that you want to use to restrict distribution of your content by country | `string` | `"none"` | no |
| <a name="input_hide_ios"></a> [hide\_ios](#input\_hide\_ios) | Do not display the Okta application icon to users on mobile app | `bool` | `false` | no |
| <a name="input_hide_web"></a> [hide\_web](#input\_hide\_web) | Do not display the Okta application icon to users | `bool` | `false` | no |
| <a name="input_ignore_public_acls"></a> [ignore\_public\_acls](#input\_ignore\_public\_acls) | Whether Amazon S3 should ignore public ACLs for this bucket | `bool` | `true` | no |
| <a name="input_ipv6_enabled"></a> [ipv6\_enabled](#input\_ipv6\_enabled) | Whether IPv6 is enabled for the distribution | `bool` | `false` | no |
| <a name="input_lambda_function_association"></a> [lambda\_function\_association](#input\_lambda\_function\_association) | A config block that triggers a lambda function with specific actions | <pre>list(object({<br>    event_type   = string<br>    include_body = bool<br>    lambda_arn   = string<br>  }))</pre> | `[]` | no |
| <a name="input_logging"></a> [logging](#input\_logging) | Enables logging for this distribution | `bool` | `true` | no |
| <a name="input_login_uri_path"></a> [login\_uri\_path](#input\_login\_uri\_path) | Optional path to the login URL | `string` | `null` | no |
| <a name="input_max_ttl"></a> [max\_ttl](#input\_max\_ttl) | Maximum amount of time (in seconds) that an object is in a CloudFront cache | `number` | `86400` | no |
| <a name="input_min_ttl"></a> [min\_ttl](#input\_min\_ttl) | Minimum amount of time that you want objects to stay in CloudFront caches | `number` | `0` | no |
| <a name="input_minimum_protocol_version"></a> [minimum\_protocol\_version](#input\_minimum\_protocol\_version) | The minimum version of the SSL protocol that you want CloudFront to use for HTTPS connections | `string` | `"TLSv1.1_2016"` | no |
| <a name="input_okta_app_name"></a> [okta\_app\_name](#input\_okta\_app\_name) | The Okta OIDC application name | `string` | `null` | no |
| <a name="input_okta_groups"></a> [okta\_groups](#input\_okta\_groups) | The default groups assigned to the Okta OIDC application | `list(string)` | `null` | no |
| <a name="input_okta_org_name"></a> [okta\_org\_name](#input\_okta\_org\_name) | The Okta organization for the OIDC application | `string` | `null` | no |
| <a name="input_okta_spa"></a> [okta\_spa](#input\_okta\_spa) | Set to true if this is a single page web application | `bool` | `false` | no |
| <a name="input_origin_path"></a> [origin\_path](#input\_origin\_path) | A path that CloudFront uses to request your content from a specific directory | `string` | `""` | no |
| <a name="input_price_class"></a> [price\_class](#input\_price\_class) | Price class for this distribution | `string` | `"PriceClass_100"` | no |
| <a name="input_redirect_uri_path"></a> [redirect\_uri\_path](#input\_redirect\_uri\_path) | Path to the login redirect URL | `string` | `"_callback"` | no |
| <a name="input_restrict_public_buckets"></a> [restrict\_public\_buckets](#input\_restrict\_public\_buckets) | Whether Amazon S3 should restrict public bucket policies for this bucket | `bool` | `true` | no |
| <a name="input_use_regional_endpoint"></a> [use\_regional\_endpoint](#input\_use\_regional\_endpoint) | Whether to use a regional instead of the global endpoint address | `bool` | `false` | no |
| <a name="input_viewer_protocol_policy"></a> [viewer\_protocol\_policy](#input\_viewer\_protocol\_policy) | Use this element to specify the protocol that users can use to access the files | `string` | `"redirect-to-https"` | no |
| <a name="input_wait_for_deployment"></a> [wait\_for\_deployment](#input\_wait\_for\_deployment) | Whether to wait for the deployment of the CloudFront Distribution to be complete | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_fqdn"></a> [application\_fqdn](#output\_application\_fqdn) | Custom FQDN pointing to the distributed application |
| <a name="output_arn"></a> [arn](#output\_arn) | ARN of the CloudFront distribution |
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | ARN of the origin bucket |
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | Name of the origin bucket |
| <a name="output_distribution_fqdn"></a> [distribution\_fqdn](#output\_distribution\_fqdn) | FQDN pointing to the distribution |
| <a name="output_etag"></a> [etag](#output\_etag) | Current version of the distribution's information |
| <a name="output_id"></a> [id](#output\_id) | ID of the CloudFront distribution |
| <a name="output_jwt_public_key"></a> [jwt\_public\_key](#output\_jwt\_public\_key) | The JWT public key |
| <a name="output_okta_client_id"></a> [okta\_client\_id](#output\_okta\_client\_id) | Okta App Client ID |
| <a name="output_status"></a> [status](#output\_status) | Current status of the distribution |
<!-- END_TF_DOCS -->
