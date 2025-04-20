#!/bin/env raku

use PDF::Lite;
use PDF::Content::Page :PageSizes, :&to-landscape;

my %m = %(PageSizes.enums);
my @m = %m.keys.sort;

# title of input pdf
my $ifile = "irrigation-plan.pdf";
# title of output pdf
my $ofile  = "irrigation-plan-scaled-up-letter.pdf";
my $ofile2 = "irrigation-plan-scaled-up-legal.pdf";

my $debug = 0;
if not @*ARGS.elems {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go | <media> [...options...]

    Produces a single scaled-up version of the input file:
        $ifile

    initially onto letter-size paper in portrait orientation as file:
        $ofile

    After the plan looks good width- and top-wise, use 'Legal' medium
    to output the file in portrait as:

        $ofile2

    With 'go', the 'Letter' media is used.

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
    when /^ :i d / { ++$debug }
    when /^ :i g / {
        $media = 'Legal';
    }
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

my $pdf = PDF::Lite.open: $ifile;
my $font = $pdf.core-font(:family<Times>, :weight<bold>);
my $font-size = 30;

#== input the existing page
my $page = $pdf.pages[1];
$page.media-box = %(PageSizes.enums){$media};
my $cx = 0.5 * ($page.media-box[2] - $page.media-box[0]);
my $cy = 0.5 * ($page.media-box[3] - $page.media-box[1]);
my @position = [$cx, $cy];
$page.graphics: {
    .Save;
    my @box = .print: "First page", :@position, :$font, :$font-size,
                      :align<center>, :valign<center>;
    .Restore;
}

# finish the document
$pdf.save-as: $ofile;

say "See output file: $ofile";

=finish

#== second page
$page = $pdf.add-page;
$page.media-box = to-landscape %(PageSizes.enums){$media};
$cx = 0.5 * ($page.media-box[2] - $page.media-box[0]);
$cy = 0.5 * ($page.media-box[3] - $page.media-box[1]);
@position = [$cx, $cy];
$page.graphics: {
    .Save;
    my @box = .print: "Second page (with \&to-landscape, no transformation)", :@position, :$font,
                      :align<center>, :valign<center>;
    .Restore;
}

#== fourth page
$page = $pdf.add-page;
$page.media-box = %(PageSizes.enums){$media};
$page.graphics: {
    .Save;
    .transform: :translate($page.media-box[2], $page.media-box[1]);
    .transform: :rotate(90 * pi/180); # left (ccw) 90 degrees
    my $w = $page.media-box[3] - $page.media-box[1];
    my $h = $page.media-box[2] - $page.media-box[0];
    $cx = 0.5 * $w;
    $cy = 0.5 * $h;
    @position = [$cx, $cy];
    my @box = .print: "Fourth page (with transformation and rotation)", :@position, :$font,
                      :align<center>, :valign<center>;
    .Restore;
}

# finish the document
$pdf.save-as: $ofile;

say "See output file: $ofile";
