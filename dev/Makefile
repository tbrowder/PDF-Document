# NOTE: Debian package 'pdfarranger' does easy page arrangement and removal

all: gbumc

TITLE =  gbumc-directory-test.pdf
LINK  =  https://gbumc-directory.org/congregation.html
#	wkhtmltopdf --page-size Letter  page https://gbumc-directory.org/congregation.html $(TITLE)

details:
	raku -e 'shell "raku --doc=Markdown docs/DETAILS.rakudoc > DETAILS.md";';

gbumc:
	wkhtmltopdf --page-size Letter  page $(LINK) $(TITLE)
