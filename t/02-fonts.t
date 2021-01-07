use Test;
use PDF::Document;

plan 15; 

for @CoreFonts -> $f {
    lives-ok {
        shell "./dev/check-fonts.raku";
    }, "checking font loading and metrics: $f";
}

lives-ok {
    shell "./dev/check-load-fonts.raku";
}, "checking loading font hash";

done-testing;
