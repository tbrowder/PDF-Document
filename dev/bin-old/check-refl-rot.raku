#!/usr/bin/env raku

use lib <./lib ../lib>;
use PDF::Document;

my $debug = 0;
my $m1  = 0;
my $m2  = 0;
my $a1  = 0;
my $a2  = 0;
sub z{$m1,$m2,$a1,$a2=0}

if not @*ARGS {
    say qq:to/HERE/;
    Usage:  {$*PROGRAM.IO.basename} go [debug][ref]

    Executes the example reflect/rotate program in the docs.
    HERE
    exit;
}
for @*ARGS {
    when /d/ { $debug = 1 }
    when /m1/ { z; $m1 = 1; }
    when /m2/ { z; $m2 = 1; }
    when /a1/ { z; $a1 = 1; }
    when /a2/ { z; $a2 = 1; }
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
#=========== THE DOCUMENT =================
# starts with a new page, current position top baseline, left margin

# for some graphics examples

my $radius = 0.5 * i2p;
my $length = $radius + 8;
.say: "circle with black left hemisphere: radius = 1/2 in:", :y<8in>;
.save;
.circle: :x<6in>, :y<8in>, :$radius, :fill;
#.line: [6*72,8*72], :$length, :angle<90d>, :linewidth(2), :color[1,0,0];
.rectangle: :cx<6.5in>, :cy<8in>, :width(2*$radius), :height(2*$radius), :fill, :color(1);
.restore;

.say: "same circle with reflection:", :y<6in>;
.save;
.page.gfx.transform: :translate[6*72,6*72];
.page.gfx.transform: :reflect(pi/2);
.circle: :x<0>, :y<0>, :$radius, :fill;
#.line: [0,0], :$length, :angle<90d>, :linewidth(2), :color[1,0,0];
.rectangle: :cx($radius), :cy(0), :width(2*$radius), :height(2*$radius), :fill, :color(1);
.restore;

my $angle = 30 * deg2rad;
.say: "original circle with +30 degree rotation:", :y<4in>;
.save;
.page.gfx.transform: :translate[6*72,4*72];
.page.gfx.transform: :rotate($angle);
.circle: :x<0>, :y<0>, :$radius, :fill;
#.line: [0,0], :$length, :angle<90d>, :linewidth(2), :color[1,0,0];
.rectangle: :cx($radius), :cy(0), :width(2*$radius), :height(2*$radius), :fill, :color(1);
.restore;


.say: "same circle with reflection:", :y<2in>;
.save;
.page.gfx.transform: :translate[6*72,2*72];
if $m1 {
    my $matrix = ref-rot-matrix :theta($angle);
    .page.gfx.transform: :$matrix;
}
elsif $m2 {
    my $matrix = rot-ref-matrix :theta($angle);
    .page.gfx.transform: :$matrix;
}
elsif $a1 {
    my $rho = ref-rot-angle :theta($angle);
    .page.gfx.transform: :reflect($rho);
}
elsif $a2 {
    my $rho = rot-ref-angle :theta($angle);
    .page.gfx.transform: :reflect($rho);
}
else {
    .page.gfx.transform: :reflect(pi/2);
    .page.gfx.transform: :rotate($angle);
}
.circle: :x<0>, :y<0>, :$radius, :fill;
#.line: [0,0], :$length, :angle<90d>, :linewidth(2), :color[1,0,0];
.rectangle: :cx($radius), :cy(0), :width(2*$radius), :height(2*$radius), :fill, :color(1);
.restore;

=begin comment
# this is the most meaningful to me for debugging:
say "========= content-dump";
my @lines  = .page.gfx.content-dump;
.say for @lines;
#say @lines.raku;
=end comment

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
my $gs2 = .page.gfx.ops;
my $gs2 = .page.gfx.open-tags;
my $gs2 = .page.gfx.tags;
=end comment

.end-doc; # renders the pdf and saves the output
          # also numbers the pages if you requested it
#=========== END THE LETTER =================
} # don't forget to close the 'given...' block

sub rot-ref-angle(:$theta, :$phi = pi/2) {
    my $rho = 2 * ($phi + 1/2 * $theta);
    return $rho;
}

sub ref-rot-angle(:$theta, :$phi = pi/2) {
    my $rho = 2 * ($phi - 1/2 * $theta);
    return $rho;
}

sub rot-ref-matrix(:$theta, :$phi = pi/2, :$convert,
    :$x = 0, :$y = 0 --> List) {
    # Returns the result of the matrix multiplication of the
    # rotation angle, theta, and
    # the reflection angle, phi (pi/2 is the default).

    # The output format is the 6-element row vector (List) used by
    # PDF::Content::Matrix.
    my $rho = 2 * ($phi + 1/2 * $theta);
    my ($a, $b, $c, $d, $e, $f);
    # the square matrix
    $a = $rho.cos;  $b =  $rho.sin;
    $c = $rho.sin;  $d = -$rho.cos;
    $e = $x.defined ?? $x !! 0;
    $f = $y.defined ?? $y !! 0;
    # The problem is how to represent the square matrix from the
    # wikipedia article in the row-matrix format used by
    # PDF::Content::Matrix: [a b c d e f]
    #
    #   where its square matrix is  [ a b 0 ]
    #                               [ c d 0 ]
    #                               [ e f 1 ]
    #
    #   and the reference matrix is [ a c ]
    #                               [ b d ]
    if $convert {
        ; # TBD
    }
    else {
        # the default Matrix format
        [$a, $b, $c, $d, $e, $f];
    }
}

sub ref-rot-matrix(:$phi = pi/2, :$theta, :$convert,
    :$x = 0, :$y = 0 --> List) {
    # Returns the result of the matrix multiplication of the
    # the reflection angle, phi (pi/2 is default), and the
    # rotation angle, theta.
    # The output format is the 6-element row vector (List) used by
    # PDF::Content::Matrix.
    my $rho = 2 * ($phi - 1/2 * $theta);
    # the square matrix
    my ($a, $b, $c, $d, $e, $f);
    $a = $rho.cos;  $b =  $rho.sin;
    $c = $rho.sin;  $d = -$rho.cos;
    $e = $x.defined ?? $x !! 0;
    $f = $y.defined ?? $y !! 0;

    if $convert {
        ; # TBD
    }
    else {
        # the default Matrix format
        [$a, $b, $c, $d, $e, $f];
    }
}
