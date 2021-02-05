#!/usr/bin/env raku

use lib <./lib ../lib>;
use PDF::Document;

my $debug = 0;
if not @*ARGS {
    say qq:to/HERE/;
    Usage:  {$*PROGRAM.IO.basename} go [debug]

    Executes the example moon phase program in the docs.
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
my \d = Doc.new: :pdf-name<example-moon-phases>, :force, :page-numbering, :$debug;

# use the 'with' block to ease typing by one character
# per command
with d {
# but you'll crash if you forget to close the block!
#=========== THE LETTER =================
# starts with a new page, current position top baseline, left margin

# moon phases waxing
# frac: 0..1

# The ideal number of cells to show ensures there is one for each of the
# named phases: New, First Quarter, Full, Third Quarter, New.
# So, [1 2 3 4 5], or [1 2 3 4 5 6 7 8 9], or [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17], etc.

# Another way to show the phases to get the same effect is to break them into waxing
# and waning groups: 
# New, First Quarter, Full
# Full, Third Quarter, New.
# That way the set of nine points works fairly well with half-inch margins.

# we want at least 9 x/y points but no more for each for waxing and
# waning, so we will use 1 row of 9 cols each to start
my $ncols = 9;
my $nrows = 1;

my $dx = (.pwidth - 72)/ $ncols;# points
my $dy = 1.00 * i2p; # points
my $xspc = 10; # points on each side of the image
my $radius = ($dx * 0.5) - (2 * $xspc);
my $frac;
my $type;
my @x; # array of x points
my @y; # array of y points
my $np = $nrows * $ncols;
my $frac-delta = 1/($np-1);

# starting points:
my $sx       = .lm * 0.5 + $dx; # for all
# northern hemisphere
my $sywax    = .pheight - (0.5 * .tm) - $dy;
my $sywane   = $sywax - 1 * $dy;

# southern hemisphere
my $sywax-s  = $sywane - 3 * $dy;
my $sywane-s = $sywax-s - 1 * $dy;

# waxing, northern hemisphere
$type = 'wax';
get-points @x, @y, :startx($sx), :starty($sywax), :$dx, :$dy, :$ncols, :$nrows;
$frac = 0;
for @y -> $cy {
    for @x -> $cx {
        note "DEBUG: moon-phase: cx = $cx, cy = $cy, radius = $radius, frac = $frac, type = $type" if $debug;
        .moon-phase: :$cx, :$cy, :$radius, :$frac, :type<wax>;
        $frac += $frac-delta;
    }
}

# waning, northern hemisphere
$type = 'wane';
get-points @x, @y, :startx($sx), :starty($sywane), :$dx, :$dy, :$ncols, :$nrows;
$frac = 1;
for @y -> $cy {
    for @x -> $cx {
        note "DEBUG: moon-phase: cx = $cx, cy = $cy, radius = $radius, frac = $frac, type = $type" if $debug;
        .moon-phase: :$cx, :$cy, :$radius, :$frac, :type<wan>;
        $frac -= $frac-delta;
    }
}

# waxing, southern hemisphere
$type = 'wax';
get-points @x, @y, :startx($sx), :starty($sywax-s), :$dx, :$dy, :$ncols, :$nrows;
$frac = 0;
for @y -> $cy {
    for @x -> $cx {
        note "DEBUG: moon-phase: cx = $cx, cy = $cy, radius = $radius, frac = $frac, type = $type" if $debug;
        .moon-phase: :$cx, :$cy, :$radius, :$frac, :type<wax>, :hemi<s>;
        $frac += $frac-delta;
    }
}

# waning, southern hemisphere
$type = 'wane';
get-points @x, @y, :startx($sx), :starty($sywane-s), :$dx, :$dy, :$ncols, :$nrows;
$frac = 1;
for @y -> $cy {
    for @x -> $cx {
        note "DEBUG: moon-phase: cx = $cx, cy = $cy, radius = $radius, frac = $frac, type = $type" if $debug;
        .moon-phase: :$cx, :$cy, :$radius, :$frac, :type<wan>, :hemi<s>;
        $frac -= $frac-delta;
    }
}



.end-doc; # renders the pdf and saves the output
          # also numbers the pages if you requested it
#=========== END THE LETTER =================
} # don't forget to close the 'given...' block

sub get-points(
    @x, @y, 
    # the start points should be at least one-half the cell width and
    # height inside the desired print area
    :$startx is copy, :$starty! is copy, 
    :$dx is copy, :$dy! is copy, 
    :$nrows = 1, 
    :$ncols = 9, 
    :$xspc,
    ) {
    # empty the point arrays
    @x = [];
    @y = [];
    if not $dx.defined {
        $dx = .width / $nrows;
    }
    if not $startx.defined {
        $startx = .lm * 0.5 + $dx;
    }

    # create the x and y points
    my ($x,$y) = $startx, $starty;
    my $n = 0;
    while $n < $ncols {
        @x.push: $x;
        $x += $dx;
        ++$n;
    }
    $n = 0;
    while $n < $nrows {
        @y.push: $y;
        $y -= $dy;
        ++$n;
    }
}

