use Test;
use PDF::Document;

plan 32;

my $p; # instantiated Point
my $b; # instantiated DocBox
my Box $box = [0, 0, 10, 20];
my Box @bad = 
    [11,  0,  10,  10], # llx > urx
    [ 0, 11,  10,  10], # lly > ury
    [-1,  0,  10,  10], # llx < 0
    [ 0, -1,  10,  10], # lly < 0
    [ 0,  0, -10,  10], # urx < 0
    [ 0,  0,  10, -10], # ury < 0
;

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

lives-ok {
    $p = Point.new: 1, 2;
}, "checking instantiation";

test-docbox $b;

for @bad -> $bad {
    dies-ok {
        $b = DocBox.new: $bad;
    }, "checking failed instantiation";
}

sub test-docbox(DocBox $b) {
    is $b.llx, 0;
    is $b.lx, 0;
    is $b.lly, 0;
    is $b.ly, 0;
    is $b.lly, 0;
    is $b.urx, 10;
    is $b.rx, 10;
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

