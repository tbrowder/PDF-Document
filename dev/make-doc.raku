#!/usr/bin/env raku

use lib <./lib ../lib>;
use PDF::Lite;
use Font::AFM;
use PDF::Document;

my \d = Doc.new;
given d {
.text: "2021-03-04";

.nl: 1; # set currentpoint x=0,y one line down from top-left corner
.text: "Dear Mom,";
.nl: 2; # resets x=0
.text: "I am fine.";
.mvto: :br; # bottom-right corner
.rmvto: :y(-2 * .leading); 
.text: "Page 1", :rj; # right justified
.np; # new page
.mvto: :tl; # top-left corner
.nl: 1; # set currentpoint x=0,y one line down from top-left corner
.text: q:to/PARA/;
A VERY long para
PARA
.nl: 2;
.text: "Love,";
.nl: 2; 
.text: "Isaiah";
.mvto: :br; # bottom-right corner
.rmvto: :y(-2 * .leading); 
.text: "Page 2 of 2", :rj; # right justified
.save: "letter.pdf";

}


