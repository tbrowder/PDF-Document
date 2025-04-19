use Test;
use PDF::Document;

is 45*deg2rad, pi/4, "testing deg2rad";
is 90*deg2rad, pi/2, "testing deg2rad";
is 135*deg2rad, 3*pi/4, "testing deg2rad";
is 180*deg2rad, pi, "testing deg2rad";
is 225*deg2rad, 5*pi/4, "testing deg2rad";
is 270*deg2rad, 3*pi/2, "testing deg2rad";
is 315*deg2rad, 7*pi/4, "testing deg2rad";
is 360*deg2rad, 2*pi, "testing deg2rad";

is rad2deg*pi/4, 45, "testing rad2deg";
is rad2deg*pi/2, 90, "testing deg2rad";
is rad2deg*3*pi/4, 135, "testing deg2rad";
is rad2deg*pi, 180, "testing deg2rad";
is rad2deg*5*pi/4, 225, "testing deg2rad";
is rad2deg*3*pi/2, 270, "testing deg2rad";
is rad2deg*7*pi/4, 315, "testing deg2rad";
is rad2deg*2*pi, 360, "testing deg2rad";

is 72, i2p, "testing i2p";
is 12*72, f2p, "testing f2p";
is 3*12*72, y2p, "testing f2p";
is 1/2.54*72, c2p, "testing c2p";
is 1/2.54*72*10, d2p, "testing d2p";
is 1/2.54*72*100, m2p, "testing m2p";
is 1/2.54*72/10, mm2p, "testing mm2p";

done-testing;
