#!/bin/env raku

my @n = 0, 128...^512;
say "sequence:", $_ for @n;
.say for @n;

=finish

#my @X = 0, 2 ... ^16;
for @n -> $n {
    say "N = $N";

    #for @X -> $X { 
    #    note "DEBUG: N = $N, X = $X, total points = {$N+$X}";
    #}
}
