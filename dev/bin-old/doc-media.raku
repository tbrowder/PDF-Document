#!/bin/env raku

use lib "../lib";

use PDF::Document;
my %m = PageSizes.enums;
my @m = %m.keys.sort;

my $debug = 0;
if not @*ARGS.elems {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} <media>

    Produces a single page of the selected media from
      the following list:

    HERE
    say "    $_" for @m;

    print qq:to/HERE/;

    Options
        d[ebug]   - debug
    HERE
    exit
}

my $Media = @*ARGS.shift;
unless %m{$Media}:exists {
    die "FATAL: Unknown media named '$Media'";
}
# title of output pdf
my $ofile = "doc-media-test-{$Media}.pdf";

for @*ARGS {
    when /^ :i d / { ++$debug          }
    when /^ :i g / {
        ; # go
    }
    default {
        note "WARNING: Unknown arg '$_'";
        note "         Exiting..."; exit;
    }
}

my $doc = Doc.new: :pdf-name($ofile), :$Media, :force, :$debug;

# write the desired pages
make-pg :$doc, :$Media; #, :landscape(True);
$doc.add-page;
make-pg :$doc, :$Media, :landscape(True);

=begin comment
for @m -> $Media {
    $doc.add-page;
    $doc.media-box = $Media;
    make-pg :$doc, :$Media; #, :landscape(True);
}
=end comment

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

    ## set the media box the same for every page
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
    $doc.print: "Media: $Media, Orientation: $orient",
                :x($cx), :y($cy), :align<center>, :valign<center>;

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
