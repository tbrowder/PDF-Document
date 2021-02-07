#!/usr/bin/env raku

use lib <./lib ../lib>;
use PDF::Document;

my $debug = 0;
if not @*ARGS {
    say qq:to/HERE/;
    Usage:  {$*PROGRAM.IO.basename} go [debug]

    Executes the example reflect/rotate program in the docs.
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
my \d = Doc.new: :pdf-name<example-reflect-rotate>, :force, :page-numbering, :$debug;

# use the 'with' block to ease typing by one character
# per command
with d {
# but you'll crash if you forget to close the block!
#=========== THE LETTER =================
# starts with a new page, current position top baseline, left margin

# for some graphics examples

my $radius = 0.5 * i2p;
.say: "circle with black left hemisphere: radius = 1/2 in:", :y<8in>;
.save;
.circle: :x<6in>, :y<8in>, :$radius, :fill;
.setgray: 1;
.rectangle: :cx<6.5in>, :cy<8in>, :width(2*$radius), :height(2*$radius), :fill;
.restore;

.say: "same circle with reflection:", :y<6in>;
.save;
.page.gfx.transform: :translate[6*72,6*72];
.page.gfx.transform: :reflect(pi/2);
.circle: :x<0>, :y<0>, :$radius, :fill;
.setgray: 1;
.rectangle: :cx($radius), :cy(0), :width(2*$radius), :height(2*$radius), :fill;
.restore;


.say: "original circle with +45 degree rotation:", :y<4in>;
.save;
.page.gfx.transform: :translate[6*72,4*72];
.page.gfx.transform: :rotate(pi/4);
.circle: :x<0>, :y<0>, :$radius, :fill;
.setgray: 1;
.rectangle: :cx($radius), :cy(0), :width(2*$radius), :height(2*$radius), :fill;
.restore;


.say: "same circle with reflection:", :y<2in>;
.save;
.page.gfx.transform: :translate[6*72,2*72];
.page.gfx.transform: :rotate(pi/4), :reflect(pi/2);
.circle: :x<0>, :y<0>, :$radius, :fill;
.setgray: 1;
.rectangle: :cx($radius), :cy(0), :width(2*$radius), :height(2*$radius), :fill;
.restore;

=begin comment
say "========= graphics-state";
my $gr  = .page.gfx.graphics-state;
say $gr.raku;

say "========= gsaves";
my $gs  = .page.gfx.gsaves;
say $gs.raku;
=end comment

=begin comment
say "========= context";
my $gc  = .page.gfx.context;
say $gc.raku;

say "========= content-dump";
my $gd  = .page.gfx.content-dump;
say $gd.raku;
=end comment

=begin comment
say "========= content-dump";
my @lines  = .page.gfx.content-dump;
.say for @lines;
#say @lines.raku;
=end comment


=begin comment
my $gs2 = .page.gfx.ops;
my $gs2 = .page.gfx.open-tags;
my $gs2 = .page.gfx.tags;
=end comment

.end-doc; # renders the pdf and saves the output
          # also numbers the pages if you requested it
#=========== END THE LETTER =================
} # don't forget to close the 'given...' block
