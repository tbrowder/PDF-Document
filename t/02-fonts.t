use Test;
use PDF::Document;

plan 14;
for @Fonts -> $f {
    lives-ok {
        shell "./dev/check-fonts.raku";
    }, "checking font loading and metrics: $f";
}

done-testing;
