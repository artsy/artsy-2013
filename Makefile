BIN = node_modules/.bin

s:
	$(BIN)/coffee scripts/server.coffee

generate:
	$(BIN)/jade src/templates/index.jade -o out
	$(BIN)/stylus src/stylesheets/index.styl -o out/ --include out/
	$(BIN)/sqwish out/index.css
	mv out/index.min.css out/index.css
	$(BIN)/browserify src/scripts/index.coffee -t coffeeify | $(BIN)/uglifyjs > out/index.js

deploy: generate
	$(BIN)/coffee scripts/to-s3.coffee $(env)
	open http://2013.artsy.net/

# Use ImageMagick to copy images from out/images/_content to resized forms.
images:
	$(foreach file, $(shell find out/images/_content/ -name '*.jpg' -exec basename {} \; | cut -d '.' -f 1), \
		convert out/images/_content/$(file).jpg -resize 640x640 -quality 40 out/images/content/$(file)-small.jpg; \
		convert out/images/_content/$(file).jpg -resize 1200x1200 -quality 80 out/images/content/$(file)-large.jpg; \
	)

.PHONY: images deploy