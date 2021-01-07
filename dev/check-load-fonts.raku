#!/usr/bin/env raku

use lib <./lib ../lib>;
use PDF::Document;
use PDF::Lite;
use Font::AFM;

# test with a pdf doc
my $pdf = PDF::Lite.new;
my %fonts;
load-core-fonts :$pdf, :%fonts;


