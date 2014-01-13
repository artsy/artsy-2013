BIN = node_modules/.bin

s:
	open out/index.html
	$(BIN)/jade src/templates/index.jade -w -o out

deploy:
	$(BIN)/coffee scripts/to-s3.coffee
	open http://2013.artsy.net/