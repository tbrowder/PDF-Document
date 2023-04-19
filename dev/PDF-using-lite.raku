#!/bin/env raku

use lib "../lib";

use PDF::Content;
use PDF::Lite;

#| copied from PDF::Content
my subset Box of List is export where {.elems == 4}
#| e.g. $.to-landscape(PagesSizes::A4)
sub to-landscape(Box $p --> Box) is export {
	[ $p[1], $p[0], $p[3], $p[2] ]
}
# These are the standard paper names and sizes copied from PDF::Content
my Array enum PageSizes is export <<
	    :Letter[0,0,612,792]
	    :Tabloid[0,0,792,1224]
	    :Ledger[0,0,1224,792]
	    :Legal[0,0,612,1008]
	    :Statement[0,0,396,612]
	    :Executive[0,0,540,720]
	    :A0[0,0,2384,3371]
	    :A1[0,0,1685,2384]
	    :A2[0,0,1190,1684]
	    :A3[0,0,842,1190]
	    :A4[0,0,595,842]
	    :A5[0,0,420,595]
	    :B4[0,0,729,1032]
	    :B5[0,0,516,729]
	    :Folio[0,0,612,936]
	    :Quarto[0,0,610,780]
	>>;
my %m = %(PageSizes.enums); #.enums;
my @m = %m.keys.sort;

# preview of title of output pdf
my $ofile = "PDF-Lite-media-test-<media>.pdf";

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
    say "Media:";
    say "  $_.raku" for @m;
    say "\nThat's all for now, folks!";
    exit;
}

#unless %m{$media}:exists {
#    die "FATAL: Unknown media named '$media'";
#}

# final title of output pdf
$ofile = "PDF-Lite-media-test-{$media}.pdf";

my $pdf = PDF::Lite.new; 
$pdf.media-box = 'Letter';

# first page
my $page = $pdf.add-page;
$page.graphics: {
    enum <x0 x1 x2 x3>;
    my $font = $pdf.core-font(:family<Helvetica>, :weight<bold>, :style<italic>);
    my @position = [300, 300];
    my @box = .say: "First page", :@position, :$font;
}

# second page
$page = $pdf.add-page;
$page.graphics: {
    enum <x0 x1 x2 x3>;
    my $font = $pdf.core-font(:family<Helvetica>, :weight<bold>, :style<italic>);
    my @position = [300, 300];
    my @box = .say: "Second page", :@position, :$font;
}

# finish the document
$pdf.save-as: $ofile;

say "See output file: $ofile";
=finish


doc = Doc.new: :pdf-name($ofile), :page-numbers, :force, :$debug;
my $pdf = $doc.pdf;
$pdf.media-box[] = [0, 0, 100, 100]; #%(PageSizes.enums){$media};
$doc.add-page;
make-page :$doc, :$media;
$doc.add-page;
make-page :$doc, :$media, :landscape<True>;

$doc.end-doc;
