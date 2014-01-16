BIN = node_modules/.bin

s:
	$(BIN)/coffee scripts/server.coffee

compile:
	$(BIN)/jade src/templates/index.jade -o out
	$(BIN)/stylus src/stylesheets/index.styl -o out/ --inline --include out/
	$(BIN)/sqwish out/index.css
	mv out/index.min.css out/index.css
	$(BIN)/browserify src/scripts/index.coffee -t coffeeify | $(BIN)/uglifyjs > out/index.js

deploy:
	$(BIN)/coffee scripts/to-s3.coffee
	open http://2013.artsy.net/