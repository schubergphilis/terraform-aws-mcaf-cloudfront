# Upgrading Notes

This document captures required refactoring on your part when upgrading to a module version that contains breaking changes.

## Upgrading to v4.0.0

### Key Changes

- Minimum required Terraform version bumped to `>= 1.9.0`.
- Added support for reusing an existing Okta application:
  - `okta_existing_app_id`
  - `okta_existing_client_id`
  - `okta_existing_client_secret`
- Authentication logic now conditionally creates the Okta app only when `okta_existing_app_id` is not set.

### Migration Notes

- Existing users are unaffected by default (all new inputs are optional and default to `null`).
- If you switch from module-managed Okta app creation to `okta_existing_app_id`, Terraform will stop managing `okta_app_oauth.default`.
- In non-SPA mode (`authentication = true` and `okta_spa = false`), when `okta_existing_app_id` is set you must also provide:
  - `okta_existing_client_id`
  - `okta_existing_client_secret`

## Upgrading to v3.0.0

### Key Changes

- `kms_key_arn` is now used to encrypt all relevant resources: SSM SecureString parameters, the authentication Lambda CloudWatch log group, and the S3 origin bucket.
- mcaf-s3 bucket upgraded to ~> 3.0.0 

## Upgrading to v2.0.0

### Key Changes

- This module now requires a minimum AWS provider version of 6.0 to support the `region` parameter. If you are using multiple AWS provider blocks, please read [migrating from multiple provider configurations](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/guides/enhanced-region-support#migrating-from-multiple-provider-configurations).
- Migrated from [Origin Access Identity to Origin Access Control](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html)
- Improved security posture by adding Security Headers.
