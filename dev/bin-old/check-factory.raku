#!/usr/bin/env raku

use lib <./lib ../lib>;
use PDF::Document;
use PDF::Lite;
use Font::AFM;

say "Tests the font factory";

# test with a pdf doc
my $pdf = PDF::Lite.new;
# quickie font factory checks

my $ff = FontFactory.new: :$pdf;
my $f = $ff.get-font: 't12d1';
$f = $ff.get-font: 't12';

say "  name: {$f.name}";
say "  size: {$f.size}";
say "  underline position: {$f.UnderlinePosition}";

$f = $ff.get-font: 'm10';
say "  name: {$f.name}";
say "  size: {$f.size}";
