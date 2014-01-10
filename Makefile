BIN = node_modules/.bin

s:
	open out/prototype.html
	$(BIN)/jade -w src/templates/prototype.jade -o out

p:
	cp -rf out/ ~/Dropbox/Public/prototype/