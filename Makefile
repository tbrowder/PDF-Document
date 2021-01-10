all:
	raku -e 'shell "raku --doc=Markdown docs/details.pod > DETAILS.md";';
