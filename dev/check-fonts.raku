#!/usr/bin/env raku

use lib <./lib ../lib>;
use PDF::Document;
use PDF::Lite;
use Font::AFM;

# test with a pdf doc
my $pdf = PDF::Lite.new;
my %f;
for @CoreFonts -> $f {
    my $F   = CoreFont.new: :name($f);
    $F.font = $pdf.core-font(:family($f));
    $F.afm  = Font::AFM.core-font($f) if $f !~~ /:i zapf /; # issue filed
    %f{$f}  = $F;
}
