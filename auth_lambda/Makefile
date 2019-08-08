clean:
	@rm -rf dist
	@rm -rf artifacts

compile: clean
	tsc

package: compile
	cp package.prod.json dist/package.json
	@cd dist && yarn install --production
	@mkdir artifacts && cd dist zip -r9 ../artifacts/index.zip .
