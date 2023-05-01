#!/usr/bin/env raku

use PDF::Lite;

if not @*ARGS {
    say qq:to/HERE/;
    Usage:  {$*PROGRAM.IO.basename} go

    Prints the "sample-text.pdf from README in module "PDF::Lite",
        a proof of concept.
    HERE
    exit;
}

use PDF::Lite;
enum <x0 y0 x1 y1>;
my PDF::Lite $pdf .= new;
#$pdf.media-box = [0, 0, 500, 150]; # original
$pdf.media-box = 'Letter';
my PDF::Lite::Page $page = $pdf.add-page;
#my $font = $page.core-font( :family<Helvetica> ); # original
my $font = $page.core-font( :family<Times-Roman> );

$page.text: -> $txt {
    my $width := 200;
    my $text = q:to"--END--";
    Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt
    ut labore et dolore magna aliqua.
    --END--

    $txt.font = $font, 12;
    # output text with left, top corner at (20, 100)
    my @box = $txt.say: $text, :$width, :position[:left(20), :top(100)];
    note "text height: {@box[y1] - @box[y0]}";

    # output kerned paragraph, flow from right to left, right, top edge at (450, 100)
    $txt.say( $text, :$width, :height(150), :align<right>, :kern, :position[450, 100] );
    # add another line of text, flowing on to the next line
    $txt.font = $page.core-font( :family<Helvetica>, :weight<bold> ), 12;
    $txt.say( "But wait, there's more!!", :align<right>, :kern );
}

$pdf.save-as: "sample-text-pdf-lite.pdf";
