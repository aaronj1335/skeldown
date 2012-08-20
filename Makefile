docs: docs/skeldown.html man/man1/skeldown.1 man/man1/skeldown.1.html

README.md: ./index.js lib/skeldown.coffee
	./$< -h > $@

docs/skeldown.html: README.md etc/skeldown/skeldown.css etc/skeldown/pipeline.js
	./index.js -e etc/skeldown/skeldown.css -j etc/skeldown/pipeline.js < $< > $@

man/man1/skeldown.1: README.md
	[ "`which ronn`" ] && ( cat $< | ronn --manual "SKELDOWN MANUAL" > $@ ) || true

man/man1/skeldown.1.html: README.md
	[ "`which ronn`" ] && ( cat $< | ronn --manual "SKELDOWN MANUAL" --html > $@ ) || true
