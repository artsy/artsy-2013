BIN = node_modules/.bin

s:
	open out/index.html
	while [ 0 -lt 1 ]; do $(BIN)/jade src/templates/index.jade -o out; sleep 0.2; done

p:
	cp -rf out/ ~/Dropbox/Public/index/