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

deploy: package
	AWS_DEFAULT_REGION=us-east-1 aws lambda update-function-code --function-name ${FUNCTION} --zip-file fileb://artifacts/index.zip
