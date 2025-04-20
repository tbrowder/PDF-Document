#!/bin/env raku

use PDF::Lite;
use PDF::Content::Page :PageSizes, :&to-landscape;

# preview of title of output pdf
my $ofile = "PDF-Lite-media-mixed-<doc number>.pdf";

my %m = %(PageSizes.enums);
my @m = %m.keys.sort;

my $debug = 0;
if not @*ARGS.elems {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go 

    Produces several two-page PDF docs illustrating different ways
    to produce pages of differing orientation and media size:

      1. 1st page: Letter, portrait 
         2nd page: Letter, landscape (with rotation)
      2. 1st page: Letter, portrait 
         2nd page: Letter, landscape (with media landscape change)
      3. 1st page: Letter, portrait 
         2nd page: A4,     portrait
      4. 1st page: Letter, portrait 
         2nd page: A4,     portrait

    HERE
    exit
}

my ($text, $page);

my $media1 = 'Letter';
my $media2 = 'Letter';
for 1..4 -> $num {
    if $num == 1 {
        ; #
    }
    elsif $num == 2 {
        ; #
    }
    elsif $num == 3 {
        $media2 = 'A4';
    }
    elsif $num == 4 {
        $media2 = 'A4';
    }

    my $pdf = PDF::Lite.new;
    my $font = $pdf.core-font(:family<Times>, :weight<bold>);

    # first page
    $pdf.media-box = %(PageSizes.enums){$media1};
    $page = $pdf.add-page;
    $text = "First page";
    make-page :$pdf, :$page, :$text, :$font, :landscape(False);

    # second page
    $page = $pdf.add-page;
    $text = "Second page";
    make-page :$pdf, :$page, :$text, :$media2, :$font, :landscape(True);

    # finish the document
    # final title of output pdf
    my $ofile = "PDF-Lite-media-mixed-{$num}.pdf";
    $pdf.save-as: $ofile;
    say "See output file: $ofile";
}

# subroutines
sub make-page(
              PDF::Lite :$pdf!,
              PDF::Lite::Page :$page!,
              :$text!,
              :$font!,
              :$media, #! is copy,
              :$media2, #! is copy,
              :$landscape,
) is export {
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
}
