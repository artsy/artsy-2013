BIN = node_modules/.bin

s:
	open out/index.html
	$(BIN)/jade src/templates/index.jade -w -o out

p:
	cp -rf out/ ~/Dropbox/Public/prototype
	open ~/Dropbox/Public/prototype