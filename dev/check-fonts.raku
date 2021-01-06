#!/usr/bin/env raku

use lib <./lib ../lib>;
use PDF::Document;
use PDF::Lite;
use Font::AFM;

# test with a pdf doc
my $pdf = PDF::Lite.new;
class Font {
    has $.name;
    has $.font is rw;
    has $.afm  is rw;
}

my %f;

for @Fonts -> $f {
    my $F   = Font.new: :name($f);
    $F.font = $pdf.core-font(:family($f));
    $F.afm  = Font::AFM.core-font($f) if $f !~~ /:i zapf /; # issue filed
    %f{$f}  = $F;
}
