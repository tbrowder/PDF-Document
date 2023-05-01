# NOTE: Debian package 'pdfarranger' does easy page arrangement and removal

#all: gbumc
#all: test99
all: test0 test1 test2 test3 test4 test88 test99

TITLE =  gbumc-directory-test.pdf
LINK  =  https://gbumc-directory.org/congregation.html
#	wkhtmltopdf --page-size Letter  page https://gbumc-directory.org/congregation.html $(TITLE)

details:
	raku -e 'shell "raku --doc=Markdown docs/DETAILS.rakudoc > DETAILS.md";';

gbumc:
	wkhtmltopdf --page-size Letter  page $(LINK) $(TITLE)

test0:
	raku -I.. ../t/*0*t	

test1: 
	raku -I.. ../t/*1*t

test2: 
	raku -I.. ../t/*2*t	

test3: 
	raku -I.. ../t/*3*t	

test4: 
	raku -I.. ../t/*4*t	

test88: 
	raku -I.. ../t/*88*t	

test99:
	(cd ..; raku -I. ./t/*99*t)
