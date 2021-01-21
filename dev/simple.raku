#!/usr/bin/env raku

use PDF::Lite;

if not @*ARGS {
    say qq:to/HERE/;
    Usage:  {$*PROGRAM.IO.basename} go

    Prints a para, a proof of concept.
    HERE
    exit;
}

my $pdf = PDF::Lite.new;
$pdf.media-box = 'Letter';
my $page = $pdf.add-page;
my $text = "I remember mama.";

my ($x0, $y0, $x1, $y1) = $page.gfx.print: $text, :position[200,200];

say "the text is {$x1-$x0} points wide and {$y1-$y0} points high";
$pdf.save-as: "simple-print.pdf";
