use Test;
use PDF::Document;

#plan 119;


my $b; # to hold the instantiated object
my Box $p = [0, 0, 10, 20];
my Box @bad = 
    [11,  0,  10,  10], # llx > urx
    [ 0, 11,  10,  10], # lly > ury
    [-1,  0,  10,  10], # llx < 0
    [ 0, -1,  10,  10], # lly < 0
    [ 0,  0, -10,  10], # urx < 0
    [ 0,  0,  10, -10], # ury < 0
;

lives-ok {
   $b = DocBox.new: $p;
}, "checking instantiation";
test-docbox $b;

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
}


done-testing;
