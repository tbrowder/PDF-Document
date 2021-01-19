all: meth

tests:
	(cd dev; gen-doc-methods.raku tests)

methods:
	(cd dev; gen-doc-methods.raku methods)

doc:
	(cd dev; gen-doc-methods.raku doc)

details:
	raku -e 'shell "raku --doc=Markdown docs/details.pod > DETAILS.md";';
