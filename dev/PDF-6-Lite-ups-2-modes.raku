#!/bin/env raku

use PDF::Lite;
use PDF::Content::Page :PageSizes, :&to-landscape;
use PDF::Content::Font;

# preview of title of output pdf
my $ofile = "PDF-Lite-ups-2-modes-<doc number>.pdf";

my %m = %(PageSizes.enums);
my @m = %m.keys.sort;

my $debug = 0;
if not @*ARGS.elems {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go

    Produces  multi-page PDF docs illustrating different ways
    to produce pages of two types of document:

    For wall calendars or similar
      3. Letter, landscape
         2nd page: Letter, landscape (upside down for flip on long-side)
         ...alternating
         ...have at least one blank interior page

      4. Same as 1 but print on back of last page

    For booklets of pictures and text
      5. 1st page: Letter, portrait
         2nd page: Letter, portrait

    HERE
    exit
}

my ($text, $page);
my $year = 2024;

my @content3 =
"The Year $year (Job d3, calendar, quick print, B&W)",
"",
"January $year",
"",
"February $year",
"";

my @content4 =
"The Year $year (Job d4, calendar, quick print, B&W)",
"(January information)",
"January $year",
"",
"February $year",
"(credits)"; # upside down if last page is even (pamphlet)

my @content5 =
"My Directory of People (Job d5, book, quick print, B&W",
"",
"Information",
"",
"(pictures...data...all remaining inside pages)",
"(back cover)";

my $media = 'Letter';

for 3..5 -> $docnum {
    my $landscape;
    my @content;

    if $docnum == 3 {
        $landscape = 1;
        @content = @content3;
    }
    elsif $docnum == 4 {
        $landscape = 1;
        @content = @content4;
    }
    elsif $docnum == 5 {
        $landscape = 0;
        @content = @content5;
    }

    my $pdf = PDF::Lite.new;

    #my $font = $pdf.core-font(:family<Times-Roman>); # good
    my $font = $pdf.core-font(:family<Times-Roman>, :weight<bold>); # good
    for 1..6 -> $page-num {
        my $reverse = 0;
        ++$reverse if $landscape and ($page-num == 6); #not ($page-num div 2)); # even

        my $text = @content[$page-num-1];

        $pdf.media-box = %(PageSizes.enums){$media};
        $page = $pdf.add-page;
        make-page :$pdf, :$page, :$text, :$font, :$media, :$landscape, :$reverse;
    }

    # finish the document
    # final title of output pdf
    my $ofile = "PDF-Lite-ups-2-modes-{$docnum}.pdf";
    $pdf.save-as: $ofile;
    say "See output file: $ofile";
}

# subroutines
sub make-page(
              PDF::Lite :$pdf!,
              PDF::Lite::Page :$page!,
              :$text!,
              :$font!,
              :$media,
              :$landscape,
              :$reverse,
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
            if $reverse {
                # translate from: lower-left  to: upper-left
                .transform: :translate($page.media-box[0], $page.media-box[3]);
                # rotate: right (cw) 90 degrees
                .transform: :rotate(-90 * pi/180); # right (cw) 90 degrees
                # lengths should be the same
                $w = $page.media-box[3] - $page.media-box[1];
                $h = $page.media-box[2] - $page.media-box[0];
            }
            else {
                # translate from: lower-left  to: lower-right
                .transform: :translate($page.media-box[2], $page.media-box[1]);
                # rotate: left (ccw) 90 degrees
                .transform: :rotate(90 * pi/180); # left (ccw) 90 degrees
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
