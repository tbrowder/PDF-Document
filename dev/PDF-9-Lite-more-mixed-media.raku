#!/bin/env raku

use PDF::Lite;
use PDF::Content::Page :PageSizes, :&to-landscape;

my %m = %(PageSizes.enums);
my @m = %m.keys.sort;

# preview of title of output pdf
my $ofile = "PDF-Lite-<media>.pdf";

my $debug = 0;
if not @*ARGS.elems {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go | <media> [...options...]

    Produces a pdf for a selected paper size
    in portrait orientation.
kd as well as two pages with
    different methods of landscape orientation.
    And one blank page has been added in the middle.

    With 'go', the 'Letter' media is used.

    Two methods of achieving landscape orientation are
    shown so the user can determine which method is needed
    for the desired results when sent to the user's printer:

      1 - swap the media-box's width and height
      2 - transform the page media-box origin
          from the lower-left corner to the
          lower-right corner, then rotate the page
          coordinate system counter-clockwise by
          90 degrees

    There are other ways to produce landscape orientation.
    Please file an issue if another method is needed for your
    printer.

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
        $media = 'Letter';
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

# final title of output pdf
$ofile = "PDF-Lite-media-simple-{$media}.pdf";

my $pdf = PDF::Lite.new;
my $font = $pdf.core-font(:family<Times>, :weight<bold>);
my $font-size = 30;

#== first page
my $page = $pdf.add-page;
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

#== third page (BLANK)
$page = $pdf.add-page;
$page.media-box = %(PageSizes.enums){$media};

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
