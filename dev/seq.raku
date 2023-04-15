#!/bin/env raku

my @N = (0, 128 ... ^512).values;
my @X = 0, 2 ... ^16;
for @N -> $N {
    say "N = $N";

    #for @X -> $X { 
    #    note "DEBUG: N = $N, X = $X, total points = {$N+$X}";
    #}
}
