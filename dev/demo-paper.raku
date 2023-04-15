#!/bin/env raku

use lib "../lib";

use PDF::Document;

# title of output pdf
my $ofile = "pdf-papers.pdf";

my $debug = 0;
if not @*ARGS.elems {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go [...options...]

    Produces a multi-page pdf demoing various paper sizes.
       PS points.

    Options
        d[ebug]   - Debug
    HERE
    exit
}

my $doc = Doc.new: :pdf-name($ofile), :force, :$debug;

my $pdf   = $doc.pdf;

# set the media-box for the current page
my $Media = <A4>;
set-media-box(:page($pdf.page), :$Media);
say $pdf.page.media-box;

# change it to the landscape orientation
set-media-box(:page($pdf.page), :$Media, :landscape);
say $pdf.page.media-box;

# see all the available media keys
$doc.show-media;

=finish
my %e = PageSizes.enums;
#say %e;
for %e.keys.sort -> $k {
    my $v = %e{$k};
    say "  key: '$k', val: '$v'";
}

