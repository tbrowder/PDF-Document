#!/bin/env raku

use PDF::Lite;
use PDF::Content::Page :PageSizes, :&to-landscape;
use PDF::Content::Font;

# preview of title of output pdf
my $ofile = "PDF-Lite-calendar-mode-ups.pdf";

my %m = %(PageSizes.enums);
my @m = %m.keys.sort;

my $debug = 0;
if not @*ARGS.elems {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go

    Produces  multi-page PDF docs illustrating
    wall calendar production at UPS.

    HERE
    exit
}

my ($text, $page);
my $year = 2024;

my @pagecontent =
"The Year $year (Job d3, calendar, quick print, B&W)",
"Jan has no special dates",
"January $year",
"",
"February $year",
"";

my $media = 'Letter';

my $landscape = 1;
my $upside-down = 0;
my $pdf = PDF::Lite.new;
my $font = $pdf.core-font(:family<Times-Roman>, :weight<bold>); # good
for 1..6 -> $page-num {
    my $text = @pagecontent[$page-num-1];
    $pdf.media-box = %(PageSizes.enums){$media};
    $page = $pdf.add-page;
    make-page :$pdf, :$page, :$text, :$font, :$media, :$landscape, :$upside-down;
}

# finish the document
$pdf.save-as: $ofile;
say "See output file: $ofile";

# subroutines
sub make-page(
              PDF::Lite :$pdf!,
              PDF::Lite::Page :$page!,
              :$text!,
              :$font!,
              :$media,
              :$landscape,
              :$upside-down,
) is export {

    # using make-page, modified, from PDF::Document.make-page
    # always save the CTM
    $page.media-box = %(PageSizes.enums){$media};
    $page.graphics: {
        # always save the CTM
        .Save;

        my ($cx, $cy);
        my ($w, $h);
        if $landscape {
            if not $upside-down {
                =begin comment
                           x=2, y=3


                x=0, y=1
                =end comment

                # translate from: lower-left corner to: lower-right corner
                # LLX, LLY -> URX, LLY
                .transform: :translate($page.media-box[2], $page.media-box[1]);
                # rotate: left (ccw) 90 degrees
                .transform: :rotate(90 * pi/180); # left (ccw) 90 degrees
                $w = $page.media-box[3] - $page.media-box[1];
                $h = $page.media-box[2] - $page.media-box[0];
            }
            else {
                # $upside-down: invert the page image
                # translate from: lower-left corner to: upper-left corner
                # LLX, LLY -> LLX, URY
                .transform: :translate($page.media-box[0], $page.media-box[3]);
                # rotate: right (cw) 90 degrees
                .transform: :rotate(-90 * pi/180); # right (cw) 90 degrees
                # lengths should be the same
                $w = $page.media-box[3] - $page.media-box[1];
                $h = $page.media-box[2] - $page.media-box[0];
            }
        }
        else {
            $w = $page.media-box[2] - $page.media-box[0];
            $h = $page.media-box[3] - $page.media-box[1];
        }

        $cx = 0.5 * $w;
        $cy = 0.5 * $h;
        my @position = [$cx, $cy];
        my @box = .print: $text, :@position, :$font,
        :align<center>, :valign<center>;

        # and restore the CTM
        .Restore;
    }

    =begin comment
    my ($cx, $cy);
    if $media {
        # use the page media-box
        $page.media-box = %(PageSizes.enums){$media};
        $cx = 0.5 * ($page.media-box[2] - $page.media-box[0]);
        $cy = 0.5 * ($page.media-box[3] - $page.media-box[1]);
    }
    else {
        $cx = 0.5 * ($pdf.media-box[2] - $pdf.media-box[0]);
        $cy = 0.5 * ($pdf.media-box[3] - $pdf.media-box[1]);
    }

    $page.graphics: {
        #my @box = .say: "Second page", :@position, :$font, :align<center>, :valign<center>;
        .print: $text, :position[$cx, $cy], :$font, :align<center>, :valign<center>;
    }
    =end comment
}
