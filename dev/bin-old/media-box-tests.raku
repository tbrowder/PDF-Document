#!/bin/env raku

use lib "../lib";

use PDF::Document;

# title of output pdf
my $ofile = "media-box-tests.pdf";
my $uofil; # for user-entered name

my $debug = 0;
if not @*ARGS.elems {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go [...options...]

    Produces pages of various media sizes

    Options
        o[file]=X - Output file name [default: $ofile]
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
    when /^ :i g / {
        ; # go
    }
    default {
        note "WARNING: Unknown arg '$_'";
        note "         Exiting..."; exit;
    }
}

if $uofil.defined  {
    $ofile = $uofil;
}

my $doc = Doc.new: :pdf-name($ofile), :$Media, :force, :$debug;

my @media = show-media :names;

# write the desired pages
for @media -> $Media {
    make-pg :$doc, :$Media, :landscape(True);
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

    # set the media box the same for every page
    my $page = $doc.page;
    set-media-box :$page, :$Media;

    my $orient = "Portrait";
    my ($llx, $lly, $urx, $ury) = $page.media-box;
    note "media-box before translation: $llx, $lly, $urx, $ury" if $debug;
    my $pw = $urx - $llx;
    if $landscape {
        # just rotate the page
        ($llx, $lly, $urx, $ury) = to-landscape $page.media-box;
        $orient = "Landscape";
        $doc.translate: $pw, 0;
        $doc.rotate(90 * deg2rad);
        note "media-box after translation: $llx, $lly, $urx, $ury" if $debug;
    }
    $pw = $urx - $llx;

    my $cx = 0.5 * ($urx-$llx);
    my $cy = 0.5 * ($ury-$lly);

    # outline the page
    # method !rectangle(Real $llx, Real $lly, Real $urx, Real $ury,

    $doc.rectangle: 72, 72, $urx-72, $ury-72;
    # text at the center
    $doc.print: $orient, :x($cx), :y($cy), :align<center>, :valign<center>;

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
