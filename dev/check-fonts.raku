#!/usr/bin/env raku

use lib <./lib ../lib>;
use PDF::Document;
use PDF;
use PDF::Lite;
use Font::AFM;

# test with a pdf doc
my $pdf = PDF::Lite.new;
my DocFont @df;
for %CoreFonts.keys.sort -> $f {
    my $F = define-docfont :$pdf, :name($f);
    @df.push: $F;
}

my TextFont %tf;
for (8,9,10,12.1) -> $size {
    for @df -> $df {
        # create a unique for the font
        my $dnam = $df.name;
        my $alias = %CoreFonts{$df.name};
        my $nam = "{$alias}{$size}";
        my $tf = set-docfont :docfont($df), :$size;
        %tf{$nam} = $tf;
        say "Setting text font '$nam'";
    }
}

