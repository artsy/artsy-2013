BIN = node_modules/.bin

s:
	$(BIN)/coffee scripts/server.coffee

deploy:
	$(BIN)/jade src/templates/index.jade -o out
	$(BIN)/coffee scripts/to-s3.coffee
	open http://2013.artsy.net/