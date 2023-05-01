use Test;
use PDF::Document;

plan 47;

my $p;  # instantiated Point

my $b;  # instantiated DocBox
my $b2; # instantiated DocBox
my $b3; # instantiated DocBox
my Box $box   = [0, 0, 10, 20];
my Box $box3  = [0, 0, 10, 20];
my $URX = 8.5 * 72;
my $URY = 11  * 72;
my Box $box2 = [0, 0, $URX, $URY]; # Letter
my Box @bad  =
    [11,  0,  10,  10], # llx > urx
    [ 0, 11,  10,  10], # lly > ury
    [-1,  0,  10,  10], # llx < 0
    [ 0, -1,  10,  10], # lly < 0
    [ 0,  0, -10,  10], # urx < 0
    [ 0,  0,  10, -10], # ury < 0
;

# box3 =================================
lives-ok {
    $b3 = DocBox.new: $box3;
}, "checking instantiation";
is $b3.landscape, False;
is $b3.w, 10;
is $b3.h, 20;
$b3.to-landscape;
is $b3.landscape, True;
is $b3.w, 20;
is $b3.h, 10;

# box2 =================================
lives-ok {
    $b2 = DocBox.new: $box2;
}, "checking instantiation";

# test to/from landscape
is $b2.landscape, False;

# test expand and shrink
lives-ok {
    $b2.shrink: 20;
}, "checking instantiation";

lives-ok {
    $b2.expand: 10;
}, "checking instantiation";
is $b2.lx, 10;
is $b2.ly, 10;
is $b2.ux, $URX-10;
is $b2.uy, $URY-10;

# box ==================================
lives-ok {
    $b = DocBox.new: $box;
}, "checking instantiation";

dies-ok {
   my $f = $b.fracx: -0.1;
}, "checking fracx out of bounds";
dies-ok {
   my $f = $b.fracx: 1.1;
}, "checking fracx out of bounds";
dies-ok {
   my $f = $b.fracy: -0.1;
}, "checking fracy out of bounds";
dies-ok {
   my $f = $b.fracy: 1.1;
}, "checking fracy out of bounds";

# point
lives-ok {
    $p = Point.new: 1, 2;
}, "checking instantiation";

for @bad -> $bad {
    dies-ok {
        $b = DocBox.new: $bad;
    }, "checking failed instantiation";
}

test-docbox $b;

sub test-docbox(DocBox $b) {
    is $b.llx, 0;
    is $b.lx, 0;
    is $b.lly, 0;
    is $b.ly, 0;
    is $b.lly, 0;
    is $b.urx, 10;
    is $b.ux, 10;
    is $b.ury, 20;
    is $b.uy, 20;

    is $b.cx, 5;
    is $b.ctrx, 5;
    is $b.cy, 10;
    is $b.cy, 10;
    is $b.ctry, 10;

    is $b.w, 10;
    is $b.width, 10;
    is $b.h, 20;
    is $b.height, 20;

    is $b.fx(.5), $b.cx;
    is $b.fy(.5), $b.cy;
}
