#!/usr/bin/env raku

use lib <./lib ../lib>;
#use PDF::Lite;
#use Font::AFM;
use PDF::Document;

if not @*ARGS {
    say qq:to/HERE/;
    Usage:  {$*PROGRAM.IO.basename} go
    
    Executes the example program in the docs.
    exit;
}

my \d = Doc.new;
given d {
.mvto: :tr; # bottom-right corner
.say: "2021-03-04", :align<right>;

.nl: 1; # set currentpoint x=0,y one line down from top-left corner
.say: "Dear Mom,";
.nl: 2; # resets x=0
.say: "I am fine.";
.mvto: :br; # bottom-right corner
.rmvto: :y(-2 * .leading); 
.say: "Page 1", :align<right>; # right justified
.np; # new page
.mvto: :tl; # top-left corner
.nl: 1; # set currentpoint x=0,y one line down from top-left corner
.say: q:to/PARA/;
A VERY long para
PARA
.nl: 2;
.say: "Love,";
.nl: 2; 
.say: "Isaiah";
.mvto: :br; # bottom-right corner
.rmvto: :y(-2 * .leading); 
.say: "Page 2 of 2", :rj; # right justified
.save: "letter.pdf";

}


