BIN = node_modules/.bin

s:
	open out/prototype.html
	$(BIN)/jade -w src/templates/prototype.jade -o out