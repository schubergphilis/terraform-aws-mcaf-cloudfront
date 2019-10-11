To create a lambda package ready for uploading to AWS, execute `make package`. This has the following dependencies:
  * typescript
  * node
  * yarn
To then deploy the updated code to Cloudfront, execute `make deploy`. This has the following dependencies/requirements:
  * export the lambda name, ie. `export FUNCTION=sg001un-production-analysis-authentication` (it will be the Lambda ending in -authentication in us-east-1)
  * A valid AWS session token (ie. make sure you are logged in through aws-okta, okta-aws, etc)
  * Install jq through apt, brew, or whatever package manager you prefer
