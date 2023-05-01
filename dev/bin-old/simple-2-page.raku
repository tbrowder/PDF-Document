#!/usr/bin/env raku

use PDF::Lite;

my $slip = 0;
if not @*ARGS {
    say qq:to/HERE/;
    Usage:  {$*PROGRAM.IO.basename} go

    Prints a para on two pages, then numbers pages, a proof of concept.
    HERE
    exit;
}

for @*ARGS {
    when /s/ { $slip = 1 }
}

my $pdf = PDF::Lite.new;
$pdf.media-box = 'Letter';
my $page = $pdf.add-page;
my $font = $page.core-font :family<Times-Roman>;
my $font-size = 18.5;
my $width = 250;
my $text = "I remember mama. And this is a very long line that should cause a wrap.";

my $np = 2;
for 1 .. $np -> $n {
    my ($x0, $y0, $x1, $y1);
    my %opt;
    %opt<width>     = $width;
    %opt<font>      = $font;
    %opt<font-size> = $font-size;
    %opt<kern>      = True;
    my $cap = %opt.Capture;
    #note "DEBUG: the Capture: {$cap.raku}";
    ($x0, $y0, $x1, $y1) = $page.gfx.say: $text, :position[72,700], |%opt;
    say "the text is {$x1-$x0} points wide and {$y1-$y0} points high";
    $page = $pdf.add-page if $n < $np;
}

my $npages = $pdf.page-count;
# try rewriting on each page
for 1 .. $npages -> $n {
    my $page = $pdf.page: $n;
    my ($x0, $y0, $x1, $y1);
    my %opt;
    %opt<width>     = $width;
    %opt<font>      = $font;
    %opt<font-size> = $font-size;
    %opt<kern>      = True;
    my $cap = %opt.Capture;
    #note "DEBUG: the Capture: {$cap.raku}";
    ($x0, $y0, $x1, $y1) = $page.gfx.say: "This is added text on the second pass: page $n of $npages", :position[72,300], |%opt;
    say "the text is {$x1-$x0} points wide and {$y1-$y0} points high";
}
my $f = "simple-2-page.pdf";
say "PDF doc $f has $npages pages.";
$pdf.save-as: $f;
say "See output file: $f":
