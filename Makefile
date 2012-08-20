docs: docs/skeldown.html man/man1/skeldown.1

README.md: ./index.js lib/skeldown.coffee
	./$< -h > $@

docs/skeldown.html: README.md
	./index.js < $< > $@

man/man1/skeldown.1: README.md
	[ "`which ronn`" ] && ( cat $< | ronn --manual "SKELDOWN MANUAL" > $@ ) || true
