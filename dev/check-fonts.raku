#!/usr/bin/env raku

use lib <./lib ../lib>;
use PDF::Document;
use PDF::Lite;
use Font::AFM;

# test with a pdf doc
my $pdf = PDF::Lite.new;
my FontFamily @ff;
for %CoreFonts.keys.sort -> $f {
    my $F = find-font :$pdf, :name($f);
    @ff.push: $F;
}

my DocFont %df;
for (8,9,10,12.1) -> $size {
    for @ff -> $ff {
        # create a unique for the font
        my $alias = %CoreFonts{$ff.name};
        my $nam = "{$alias}{$size}";
        my $df = select-font :fontfamily($ff), :$size;
        %df{$nam} = $df;
        say "Setting document font '$nam'";
    }
}

