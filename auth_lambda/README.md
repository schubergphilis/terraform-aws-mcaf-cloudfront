# Deployment

To update the Lambda package, execute `make package`. This has the following dependencies:
  * typescript
  * node
  * yarn

To deploy the latest package, commit the new artifact to get deployed automatically, or deploy manually by executing `make deploy`. This has the following dependencies/requirements:
  * export the lambda name, ie. `export FUNCTION=awesome-app-production-authentication` (it will be the Lambda ending in -authentication in us-east-1)
  * A valid AWS session token (ie. make sure you are logged in through aws-okta, okta-aws, etc)
  * Install jq through apt, brew, or whatever package manager you prefer
