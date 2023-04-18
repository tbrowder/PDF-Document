#!/bin/env raku

use lib "../lib";

use PDF::Document;

# title of output pdf
my $ofile = "ps-no-rotate-2page-port-land-test.pdf";
my $uofil; # for user-entered name

my $debug = 0;
if not @*ARGS.elems {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go [...options...]

    Produces two pages, portrait and landscape, with no rotation.

    Options
        o[file]=X - Output file name [default: $ofile]
        1         - First page only
        a         - Use A4 paper
        L         - Landscape
        d[ebug]   - Debug
    HERE
    exit
}

my $A4  = 0;
my $one = 0;
my $landscape = False;
my $reverse   = False;
for @*ARGS {
    when /^ :i o[file]? '=' (\S+) / {
        $uofil = ~$0;
    }
    when /^ :i d / { ++$debug          }
    when /^ :i 1 / { ++$one            }
    when /^ :i a / { ++$A4             }
    when /^ :i L / { $landscape = True }
    when /^ :i R / { $reverse   = True }
    when /^ :i g / {
        ; # go
    }
    default {
        note "WARNING: Unknown arg '$_'";
        note "         Exiting..."; exit;
    }
}

my $Media;
if $A4 {
    $Media = 'A4';
}
else {
    $Media = 'Letter';
}

if $uofil.defined  {
    $ofile = $uofil;
}
my $doc = Doc.new: :pdf-name($ofile), :$Media, :force, :$debug;

# write the desired pages
# ...
# start the document with the first page
if $reverse {
    make-pg :$doc, :$Media, :landscape(True);
    $doc.add-page;
    make-pg :$doc, :$Media, :landscape(False);
}
else {
    make-pg :$doc, :$Media, :$landscape;
    if not $one {
        $doc.add-page;
        make-pg :$doc, :$Media, :landscape(True);
    }
}
# save the doc with name as desired
$doc.end-doc;

sub make-pg(
    Doc :$doc!,
    # payload
    :$Media!,     # paper name (e.g., Letter, A4)
    :$landscape = False,
    :$debug,

) is export {
    # media-box - width and height of the rendered page
    # crop-box  - region of the PDF that is displayed or printed
    # trim-box  - width and height of the printed page

    # always save the default CTM
    $doc.save;

    my $page = $doc.page;
    my $orient = "Portrait";
    if $landscape {
        # just adjust the media-box
        $orient = "Landscape";
        set-media-box :$page, :$Media, :$landscape;
    }
    else {
        set-media-box :$page, :$Media;
    }
    my $cx = $doc.mb(:cx); #0.5 * $PW;
    my $cy = $doc.mb(:cy); #0.5 * $PH;

    # outline the page
    # method !rectangle(Real $llx, Real $lly, Real $urx, Real $ury,

    #my @points = 72, 72, $PW-72, $PH-72;
    $doc.rectangle: 72, 72, $doc.mb(:w)-72, $doc.mb(:h)-72;
    # text at the center
    $doc.print: $orient, :x($cx), :y($cy), :align<center>;

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
