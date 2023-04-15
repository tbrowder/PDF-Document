#!/bin/env raku

use lib "../lib";

require PDF::Document;
use PDF::Document;

# title of output pdf
my $npsh  = 6; # number of groups of 128 of PS points
my $nps   = $npsh * 128;
my $ofile = "ps-ruler-$nps.pdf";
my $uofil; # for user-entered name

my $debug = 0;
if not @*ARGS.elems {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go [...options...]

    Produces a PostScript point ruler of length
       PS points.

    Options
        o[file]=X - Output file name [default: $ofile]
        a         - Use A4 paper
        n=N       - Make length N x 100 points
        L         - Landscape

        d[ebug]   - Debug
    HERE
    exit
}

my $A4 = 0;
my $landscape = 0;
for @*ARGS {
    when /^ :i o[file]? '=' (\S+) / {
        $uofil = ~$0;
    }
    when /^ :i 'n=' (\d+) $/ {
        $npsh = +$0;
    }
    when /^ :i d / { ++$debug     }
    when /^ :i a / { ++$A4        }
    when /^ :i L / { ++$landscape }
    when /^ :i g / {
        ; # go
    }
    default {
        note "WARNING: Unknown arg '$_'";
        note "         Exiting..."; exit;
    }
}

$nps = $npsh * 128;
if $uofil.defined  {
    $ofile = $uofil;
}
else {
    $ofile = "ps-ruler-$nps-{$landscape}.pdf";
}

my $doc = Doc.new: :pdf-name($ofile), :force, :$debug;
my ($PW, $PH); # paper width, height (portrait)
my ($LM, $TM, $RM, $BM); # margins (in final orientation)
$LM = 0.5 * 72;
$TM = 0.5 * 72;
$BM = $LM;
$RM = $LM;

if $A4 {
    $PW =  8.3  * 72;
    $PH = 11.7  * 72;
}
else {
    $PW =  8.5  * 72;
    $PH = 11.0  * 72;
}

# write the desired pages
# ...
# start the document with the first page
make-ps :$doc, :$PW, :$LM, :$BM, :$npsh, :$nps;
#$doc.add-page;
#make-ps :$doc, :$PW, :$LM, :$BM, :$npsh, :$nps;

# save the doc with name as desired
$doc.end-doc;

sub make-ps(
    Doc :$doc!,
    # payload
    :$npsh!,
    :$nps!,
    :$PW!, :$LM!, :$BM!,
    :$landscape = 0,

    :$debug,

) is export {
    # media-box - width and height of the printed page
    # crop-box  - region of the PDF that is displayed or printed
    # trim-box  - width and height of the printed page

    # always save the default CTM
    $doc.save;

    if $landscape {
        # transform coordinate system for landscape, origin
        # at lower-left corner of the page
        $doc.translate($PW, 0);
        $doc.rotate(90 * deg2rad);
    }

    # outline the page
    # method !rectangle(Real $llx, Real $lly, Real $urx, Real $ury,
    #my @points = 72, 72, $PW-72, $PH-72;
    $doc.rectangle: 72, 72, $PW-72, $PH-72;

    # hard horizontal dimensions:
    #   0 point (leave room for a pretty end
        my $x0 = $LM + 1 * 72;
    # hard vertical dimensions:
    #   bottom of the ruler above the bottom margin BM
        my $yb = $BM;
    #   top of the ruler above its bottom
        my $yt = 1.5 * 72 + $yb;
    #   height of the various point marks
        my $h0 = 4; # base length
        my $h1 = 6; # every fifth
        my $h2 = 8; # every 10th (with number)

    # multi method line(List $from, :$length!, :$angle!,
    #     :$color = [0], # black
    #     :$linewidth = 0

    my ($x, $y, @from, $angle, $length, $total);
    my $linewidth = 0;
    # sub deg2rad($d) { $d * pi / 180 }
    #my @N = 0, 128 ... ^$nps;
    #my @X = 0, 2 ... ^128;
    loop (my $i = 0; $i < $nps; $i += 128) {
        my $N = $i;
        # make block of 128 at a time (top and bottom scales)
        # make a mark every 2 points
        loop (my $j = 0; $j < 128; $j += 2) {
            my $X = $j;
            note "DEBUG: N = $N, X = $X, total points = {$N+$X}" if $debug;
            $x = $N + $X + $x0;
            $length = $h0;

            # top: vertical lines pointing down, names at bottom
            @from = $x, $yt;
            $angle = 270 * deg2rad;
            $doc.line: @from, :$length, :$angle;

            # bottom: vertical lines pointing up, names at top
            @from = $x, $yb;
            $angle = 90 * deg2rad;
            $doc.line: @from, :$length, :$angle;
        }
    }

    # always restore the CTM
    $doc.restore;
}

sub put-text(
    PDF::Lite::Page :$page!,
    DocFont :$font!,
    :$debug) is export {

    $page.text: -> $txt {
        $txt.font = $font, 10;
        my $text = "Other text";
	$txt.text-position = 200, 200;
        $txt.say: $text, :align<center>; #, :valign<baseline>;
    }
}
