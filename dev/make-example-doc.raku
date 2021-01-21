#!/usr/bin/env raku

use lib <./lib ../lib>;
#use PDF::Lite;
#use Font::AFM;
use PDF::Document;

if not @*ARGS {
    say qq:to/HERE/;
    Usage:  {$*PROGRAM.IO.basename} go
    
    Executes the example program in the docs.
    HERE
    exit;
}

my \d = Doc.new;

given d {
# top-right corner
.print: "2021-03-04", :tr, :align<right>, :valign<top>, :nl;

.nl: 1; # set currentpoint x=0,y one line down from top-left corner
.print: "Dear Mom,";
.nl: 2; # resets x=0
.print: "I am fine.";
.mvto: :br; # bottom-right corner
.rmvto: 0, -2 * .leading; 
.print: "Page 1", :align<right>; # right justified
.np; # new page
.mvto: :tl; # top-left corner
.nl: 1; # set currentpoint x=0,y one line down from top-left corner
.print: q:to/PARA/;
A VERY long para
PARA
.nl: 2;
.print: "Love,";
.nl: 2; 
.print: "Isaiah";
.mvto: :br; # bottom-right corner
.rmvto: 0, -2 * .leading; 
.print: "Page 2 of 2", :rj; # right justified
.save: "example-letter.pdf";

}


