#!/bin/env raku

use PDF::Lite;
use PDF::Font::Loader;
use PDF::Content::Color :ColorName, :&color;

#use lib <../lib>;
#use Calendar;
#use Calendar::Vars;

# title of output pdf
my $ofile = "landscape-grid.pdf";

my $debug = 0;
if not @*ARGS.elems {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go [...options...]

    Produces a test PDF

    Options
        o[file]=X - Output file name [default: $ofile]
        a         - Use A4 paper

        d[ebug]   - Debug
    HERE
    exit
}

my $A4 = 0;
for @*ARGS {
    when /^ :i o[file]? '=' (\S+) / {
        $ofile = ~$0;
    }
    when /^ :i d / { ++$debug }
    when /^ :i a / { ++$A4    }
    when /^ :i g / {
        ; # go
    }
    default {
        note "WARNING: Unknown arg '$_'";
        note "         Exiting..."; exit;
    }
}

my ($PW, $PH); # paper width, height (portrait)
my ($LM, $TM, $RM, $BM); # margins (in final orientation)
$LM = 0.5  * 72;
$TM = 0.75 * 72;
if $A4 {
    $PW =  8.3  * 72;
    $PH = 11.7  * 72;
}
else {
    $PW =  8.5  * 72;
    $PH = 11.0  * 72;
}

# Do we need to specify 'media-box' on the whole document?
# No, it can be set per page.
my $pdf = PDF::Lite.new;
$pdf.media-box = $A4 ?? 'A4' !!'Letter';
my $font  = $pdf.core-font(:family<Times-RomanBold>);
my $font2 = $pdf.core-font(:family<Times-Roman>);

# write the desired pages
# ...
# start the document with the first page
make-page :$pdf, :$PW;
make-page :$pdf, :$PW;

my $pages = $pdf.Pages.page-count;
# save the whole thing with name as desired
$pdf.save-as: $ofile;
say "See outout pdf: $ofile";
say "Total pages: $pages";

sub deg2rad($d) { $d * pi / 180 }

sub make-page(
    PDF::Lite :$pdf!,

    # payload
    #Calendar :$cal,
    #UInt :$month, # month number
    :$PW,

    :$debug,
    
) is export {
    # media-box - width and height of the printed page
    # crop-box  - region of the PDF that is displayed or printed
    # trim-box  - width and height of the printed page
    my $page = $pdf.add-page;
    my $gfx  = $page.gfx;

    # always use landscape orientation
    $gfx.Save;
    # transform coordinate system for landscape, origin
    # at lower-left corner of the page
    $gfx.transform: :translate[$PW, 0];
    # positive angle: anti-clockwise (rotate left)
    $gfx.transform: :rotate(deg2rad(90)); 

    # hard vertical dimensions:
    #   bottom of the 6-week grid above the bottom margin BM
    #   top of the 6-week grid above its bottom
    #   height of the week-day column names

    # font names and sizes:
    #   month/year title - Times-Bold 20 pt
    #   monthly quotes - Times-Italic 15 pt
    #   day text:
    #     line-space-ratio - 1.05
    #     white-on-black day-of-week - Helvetica-Bold 12 pt
    #     holidays, birthdays, etc. - Times-Bood 10 pt, indent 5
    #                               
    #     day number - Helvetica 12 pt (outline for "negative" day numbers)
    #                  offset x - 4 pt from the right of cell
    #                  offset y - 12 * line-space-ratio from top of cell
    #     sun rise/set
    #     moon phase
    #     moon phase symbol 0.3 in from bottom of the cell

    # make the title line (month, year

    # make the sayings line

    # make the grid (dow, then 4, 5, or 6 weeks)
    my $nweeks = 6; #weeks-in-month $cal.year
    my $width  = ($PH - 2 * $LM)/7; # use full width less two margins
    # leave space for title and cell header row
    my $title-baseline = 72;
    my $grid-top-space = 10;
    my $cell-hdr = 10;
    my $height = ($PH - 2 * $LM)/6;

    for (20, 40 ... 200)  -> $x {
        for 20, 40, 60 -> $y {
            $gfx.&make-box: :$x, :$y, :$width, :$height;
        }
    }

    # fill each cell appropriately
    #   create a mapping from day-of-week and week-of-month
    #   to cell in the grid




    # must alway restore the CTM
    $gfx.Restore;
}

# subs for gfx calls (I do not understand this!!)
# but I'm getting the drift of it
sub make-box($_,
    :$x!, :$y!, :$width!, :$height!,
    :$linewidth = 2,
    :$debug,
    # payload
) is export {
    # given the bottom-left corner, dimensions, etc
    # draw the box
    # must save the CTM
    .Save;

    # transform to the bottom-left corner
    .transform: :translate[$x, $y];
    .Rectangle: 0, 0, $width, $height;
    .CloseStroke;

    # print or draw the data

    # restore the CTM
    .Restore;
}

sub put-text(
    PDF::Lite::Page :$page!, 
    :$debug) is export {

    $page.text: -> $txt {
        $txt.font = $font, 10;
        my $text = "Other text";
	$txt.text-position = 200, 200;
        $txt.say: $text, :align<center>; #, :valign<baseline>;
    }
}
