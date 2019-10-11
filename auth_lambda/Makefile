clean:
	rm -rf dist
	rm -rf artifacts

compile: clean
	yarn install
	tsc

package: compile
	cp package.prod.json dist/package.json
	cd dist && yarn install --production
	mkdir artifacts && cd dist && zip -r9 ../artifacts/index.zip .

deploy:
	AWS_DEFAULT_REGION=us-east-1 aws lambda update-function-code --function-name ${FUNCTION} --zip-file fileb://artifacts/index.zip
	export ARN=`AWS_DEFAULT_REGION=us-east-1 aws lambda publish-version --function-name ${FUNCTION} --output text --query 'FunctionArn'`
	export CLOUDFRONT_ID=`aws cloudfront list-distributions --output text --query 'DistributionList.Items[0].Id'`
	export ETAG=`aws cloudfront get-distribution-config --id ${CLOUDFRONT_ID} --output text --query 'ETag'`
	aws cloudfront get-distribution-config --id ${CLOUDFRONT_ID} | sed "s/\"LambdaFunctionARN\": \".*\"/\"LambdaFunctionARN\": \"${ARN}\"/" | jq .DistributionConfig > artifacts/config.json
	aws cloudfront update-distribution --id ${CLOUDFRONT_ID} --distribution-config file://artifacts/config.json --if-match ${ETAG}
