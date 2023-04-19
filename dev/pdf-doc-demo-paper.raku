#!/bin/env raku

use lib "../lib";

use PDF::Document;

# preview of title of output pdf
my $ofile = "PDF-Document-media-test-<media>.pdf";

my $debug = 0;
if not @*ARGS.elems {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} <media> [...options...]

    Produces a two-page pdf for a selected paper size
      in portrait as well as landscape orientation.

    Options
        s[How]    - Show all known media and exit
        d[ebug]   - Debug
    HERE
    exit
}

my $media;
my $show = 0;
my %m = PageSizes.enums;
my @m = %m.keys.sort;
for @*ARGS {
    when /^ :i s / {
        ++$show;
        last
    }
    when /^ :i d / { ++$debug        }
    default {
        # the media selection
        $media = $_;
    }
}

if $show {
    my $doc = Doc.new;
    $doc.show-media;
    say "\nThat's all for now, folks!";
    exit;
}

unless %m{$media}:exists {
    die "FATAL: Unknown media named '$media'";
}

# final title of output pdf
$ofile = "PDF-Document-media-test-{$media}.pdf";

my $doc = Doc.new: :pdf-name($ofile), :page-numbers, :force, :$debug;
my $pdf = $doc.pdf;
$pdf.media-box[] = [0, 0, 100, 100]; #%(PageSizes.enums){$media};
$doc.add-page;
make-page :$doc, :$media;
$doc.add-page;
make-page :$doc, :$media, :landscape<True>;

$doc.end-doc;
