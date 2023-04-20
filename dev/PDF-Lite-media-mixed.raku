#!/bin/env raku

use PDF::Lite;

# preview of title of output pdf
my $ofile = "PDF-Lite-media-mixed-<media>.pdf";

#| copied from PDF::Content
my subset Box of List is export where {.elems == 4}
#| e.g. $.to-landscape(PagesSizes::A4)
sub to-landscape(Box $p --> Box) is export {
    [ $p[1], $p[0], $p[3], $p[2] ]
}

# These are three of the standard paper names and sizes copied from PDF::Content
my Array enum PageSizes is export <<
    :Letter[0,0,612,792]
    :Legal[0,0,612,1008]
    :A4[0,0,595,842]
>>;
my %m = %(PageSizes.enums);
my @m = %m.keys.sort;

my $debug = 0;
if not @*ARGS.elems {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} <media> [...options...]

    Produces a two-page pdf for a selected paper size
      in portrait as well as landscape orientation.

    Options
        j[how] - Show all known media and exit
        f=X    - Select font family X is one of: Times Helvetica
        w=X    - Select font weight X is one of: Bold Italic BoldItalic
        s=X    - Select font size (points) X
        d      - Debug
    HERE
    exit
}

my $media;
my $show = 0;
for @*ARGS {
    when /^ :i 'f=' (\S+) / {
        $font = ~$0;
    }
    when /^ :i 'w=' (\S+) / {
        $weight = ~$0;
    }
    when /^ :i 's=' (\S+) / {
        $size = +$0;
    }
    
    when /^ :i s / { # <= special exit from arg list
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
    say "Media:\n";
    say "  $_" for @m;
    say "\nThat's all for now, folks!";
    exit;
}

unless %m{$media}:exists {
    die "FATAL: Unknown media named '$media'";
}

# final title of output pdf
$ofile = "PDF-Lite-media-mixed-{$media}.pdf";

my $pdf = PDF::Lite.new;
$pdf.media-box = %(PageSizes.enums){$media};

my $font = $pdf.core-font(:family<Helvetica>, :weight<bold>);

my ($text, $page);

# first page
$page = $pdf.add-page;
# sub make-page(:$page!, :$text!, :$media!, :$font, :$landscape, 
$text = "First page";
make-page :$page, :$text, :$media, :$font, :landscape(False);

# second page
$page = $pdf.add-page;
$text = "Second page";
make-page :$page, :$text, :$media, :$font, :landscape(True);

# finish the document
$pdf.save-as: $ofile;

say "See output file: $ofile";

# subroutines
sub make-page(PDF::Lite::Page :$page!, 
             :$text!, 
             :$media! is copy,
             :$font!,
             :$landscape, 
) is export {
    $page.media-box = %(PageSizes.enums){$media};

    my $cx = 0.5 * ($pdf.media-box[2] - $pdf.media-box[0]);
    my $cy = 0.5 * ($pdf.media-box[3] - $pdf.media-box[1]);
    $page.graphics: {
        #my @box = .say: "Second page", :@position, :$font, :align<center>, :valign<center>;
        .say: $text, :position[$cx, $cy], :$font, :align<center>, :valign<center>;
    }
}
