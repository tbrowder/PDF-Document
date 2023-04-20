#!/bin/env raku

use PDF::Lite;

# These are three of the standard paper names and sizes copied from PDF::Content
my Array enum PageSizes is export <<
    :Letter[0,0,612,792]
    :Legal[0,0,612,1008]
    :A4[0,0,595,842]
>>;
my %m = %(PageSizes.enums);
my @m = %m.keys.sort;

# preview of title of output pdf
my $ofile = "PDF-Lite-media-simple-<media>.pdf";

my $debug = 0;
if not @*ARGS.elems {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} <media> [...options...]

    Produces a two-page pdf for a selected paper size
      in portrait as well as landscape orientation.

    Options
        s[how] - Show all known media and exit
    HERE
    exit
}

my $media;
my $show = 0;
for @*ARGS {
    when /^ :i s / {
        ++$show;
        last
    }
    when /^ :i d / { ++$debug        }
    default {
        # the media selection
        $media = $_.tc;
    }
}

if $show {
    say "Media:";
    say "  $_" for @m;
    say "\nThat's all for now, folks!";
    exit;
}

unless %m{$media}:exists {
    die "FATAL: Unknown media named '$media'";
}

# final title of output pdf
$ofile = "PDF-Lite-media-simple-{$media}.pdf";

my $pdf = PDF::Lite.new;
$pdf.media-box = %(PageSizes.enums){$media};
my $font = $pdf.core-font(:family<Times>, :weight<bold>);
my $font-size = 30;
my $cx = 0.5 * ($pdf.media-box[2] - $pdf.media-box[0]);
my $cy = 0.5 * ($pdf.media-box[3] - $pdf.media-box[1]);

my @position = [$cx, $cy];

# first page
my $page = $pdf.add-page;
$page.graphics: {
    my @box = .print: "First page", :@position, :$font, :$font-size, :align<center>, :valign<center>;
}

# second page
$page = $pdf.add-page;
$page.graphics: {
    my @box = .print: "Second page", :@position, :$font, :align<center>, :valign<center>;
}

# finish the document
$pdf.save-as: $ofile;

say "See output file: $ofile";
