#!/usr/bin/env raku

use PDF::Document;

my $debug = 0;
if not @*ARGS {
    say qq:to/HERE/;
    Usage:  {$*PROGRAM.basename} go [debug]

    A simple example of Doc use.
    HERE
    exit;
}

for @*ARGS {
    when /d/ { $debug = 1 }
}

# We change only three of the many defaults for this
# example: (1) output file name, (2) force option to
# allow overwriting that file if it exists, and (3)
# turn page numbering on:
my $doc = Doc.new: :pdf-name<simple-doc>, :force, :page-numbering, :$debug;

$doc.end-doc; # renders the pdf and saves the output
              # also numbers the pages if you requested it

sub make-page(Doc :$doc) {
    # starts with a new page, current position top baseline, left margin
    # put the date at the top-right corner
    $doc.print: "2021-03-04", :tr, :align<right>, :valign<top>;
    $doc.nl; # adds the newline, resets x to left margin
}

=finish

#=========== THE LETTER =================
# starts with a new page, current position top baseline, left margin

# put the date at the top-right corner
d.print: "2021-03-04", :tr, :align<right>, :valign<top>;
d.nl; # adds the newline, resets x to left margin

d.say: "Dear Mom,"; # SHOULD automatically add a newline
d.nl: 1; # moves y down one line, resets x=0 (left margin)
d.say: "I am fine.";
d.nl: 1;
d.say: "How are you?";

# simple graphics: circle, etc.
d.nl: 30;
d.say: "circle: radius = 36 pts, linewidth = 4 points";
d.save; # save the current position and graphics state
d.circle: :x<5in>, :y<3in>, :radius(36), :linewidth(4); # default points (or in, cm)
d.restore; # don't forget to go back to normal!

d.np; # new page, current position top baseline, left margin
d.say: q:to/PARA/;
Pretend this is a VERY long para
that extends at least more than one line length in the
current font so we can observe the effect of  paragraph
wrapping. Isn't this swell!
PARA

d.nl: 3;

d.say: "Thats all, folks, but see following pages for other bells and whistles!";
d.nl: 2;
d.say: "Love,";
d.nl: 2;
d.say: "Isaiah";

d.np; # for some graphics examples

d.say: "ellipse: a = 1 in, b = 0.5 in", :y<8in>;
d.ellipse: :x<5in>, :y<8in>, :a<1in>, :b<.5in>;

d.say: "ellipse: a = 0.3 in, b = 2 cm", :y<6in>;
d.ellipse: :x<5in>, :y<6in>, :a<.3in>, :b<2cm>;

d.say: "circle: radius = 24 mm", :y<4in>;
d.circle: :x<5in>, :y<4in>, :radius<24mm>;

d.say: "rectangle: width = 2 in, height = 2 cm", :y<2in>;
d.rectangle: :llx<5in>, :lly<2in>, :width<2in>, :height<2cm>;

d.np; # for some more graphics examples

d.say: "polyline:", :y<7.5in>;
my @pts = 1*i2p, 7*i2p, 4*i2p, 6.5*i2p, 3*i2p, 5*i2p;
d.polyline: @pts;

d.say: "blue polygon:", :y<4.5in>;
@pts = 1*i2p, 4*i2p, 4*i2p, 3.5*i2p, 3*i2p, 2*i2p;
d.polygon: @pts, :fill, :color[0,0,1]; # rgb, 0-1 values


d.end-doc; # renders the pdf and saves the output
          # also numbers the pages if you requested it
#=========== END THE LETTER =================
