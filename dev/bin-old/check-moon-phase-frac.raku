#!/usr/bin/env raku

say "Tests the frac calc for moon phase wax/wane.";

my @f;
my $r = 2;
say qq:to/HERE/;
--------------------------------------
Waxing, frac varies from 0 to 0.5 to 1.
given frac:
    frac = 0.0, a = r
    frac = 0.5, a = 0
    frac = 1.0, a = r 
HERE

say "Waxing, f < 0.5, radius = $r:";
@f = 0, .25, .5;
for @f -> $f {
    my $a = $r - (2 * $r * $f);
    say "  frac = $f, a = $a";
}
say "Waxing, f > 0.5, radius = $r:";
@f = .5, .75, 1;
for @f -> $f {
    my $a = (2 * $r * $f) - $r;
    say "  frac = $f, a = $a";
}

say qq:to/HERE/;
--------------------------------------
Waning, frac varies from 1 to 0.5 to 0.
given frac:
    frac = 1.0, a = r 
    frac = 0.5, a = 0
    frac = 0.0, a = r
HERE
say "Waning, f > 0.5, radius = $r:";
@f = 1, .75, .5;
for @f -> $f {
    my $a = (2 * $r * $f) - $r;
    say "  frac = $f, a = $a";
}
say "Waning, f < 0.5, radius = $r:";
@f = .5, .25, 0;
for @f -> $f {
    my $a = $r - (2 * $r * $f);
    say "  frac = $f, a = $a";
}
