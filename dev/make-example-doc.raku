#!/usr/bin/env raku

use lib <./lib ../lib>;
use PDF::Document;

if not @*ARGS {
    say qq:to/HERE/;
    Usage:  {$*PROGRAM.IO.basename} go

    Executes the example program in the docs.
    HERE
    exit;
}

# We change only three of the many defaults for this
# example: (1) output file name, (2) force option to
# allow overwriting that file if it exists, and (3)
# turn page numbering on:
my \d = Doc.new: :pdf-name<example-letter>, :force, :page-numbering;

# use the 'with' block to ease typing by one character
# per command
with d {
# but you'll crash if you forget to close the block!
#=========== THE LETTER =================
# starts with a new page, current position top baseline, left margin

# put the date at the top-right corner
.print: "2021-03-04", :tr, :align<right>, :valign<top>;
.say: ""; # adds the newline, resets x to left margin

.say: "Dear Mom,"; # automatically adds a newline
.nl: 1; # moves y down one line, resets x=0 (left margin)
.say: "I am fine.";

.say: "How are you?";

# simple graphics: circle, etc.
.nl: 30;
.say: "circle: radius = 36 pts, linewidth = 4 points";
.save; # save the current position and graphics state
.setlinewidth: 4; # points
.circle: :x<5in>, :y<3in>, :radius(36); # default points (or in, cm)
.restore; # don't forget to go back to normal!

.np; # new page, current position top baseline, left margin
.say: q:to/PARA/;
Pretend this is a VERY long para
that extends at least more than one line length in the
current font so we can observe the effect of  paragraph
wrapping. Isn't this swell!
PARA

.say: "Thats all, folks, but see following pages for other bells and whistles!";
.nl: 2;
.say: "Love,";
.nl: 2;
.say: "Isaiah";

.np; # for some graphics examples

.say: "ellipse: a = 1 in, b = 0.5 in", :y<8in>;
.ellipse: :x<5in>, :y<8in>, :a<1in>, :b<.5in>;

.say: "ellipse: a = 0.3 in, b = 2 cm", :y<6in>;
.ellipse: :x<5in>, :y<6in>, :a<.3in>, :b<2cm>;

.say: "circle: radius = 24 mm", :y<4in>;
.circle: :x<5in>, :y<4in>, :radius<24mm>;

.say: "rectangle: width = 2 in, height = 2 cm", :y<2in>;
.rectangle: :llx<5in>, :lly<2in>, :width<2in>, :height<2cm>;

.np; # for some more graphics examples

.say: "polyline:", :y<7in>;
my @pts = 1*i2p, 7*i2p, 4*i2p, 6.5*i2p, 3*i2p, 5*i2p;
.polyline: @pts;


.say: "polygon:", :y<4in>;
@pts = 1*i2p, 4*i2p, 4*i2p, 3.5*i2p, 3*i2p, 2*i2p;
.polygon: @pts;

.np; # for some more graphics examples

# moon phases waxing
# frac: 0..1
my @x = 0.5, 1, 2, 3, 4, 5, 6; # inches from the left margin
my @y = 0.5, 1, 2, 3, 4, 5, 6, 7, 8, 9; # inches from the top margin
my $np = @x.elems * @y.elems * 1;
my $p = 0;
my $radius = 0.4 * i2p;
my $frac = 0;
my $frac-delta = 1/($np-1);
PTS: for @y -> $y {
    my $dy = $y * i2p;
    my $cy = .pheight - .tm - $dy;
    for @x -> $x {
        my $cx = $x * i2p;
        .moon-phase: :$cx, :$cy, :$radius, :$frac, :type<wax>;
        last PTS if 1;
        $frac += $frac-delta;
    }
}




.end-doc; # renders the pdf and saves the output
          # also numbers the pages if you requested it
#=========== END THE LETTER =================
} # don't forget to close the 'given...' block
