use Test;
use PDF::Document;

plan 1; 


#for @CoreFonts -> $f {
#}

lives-ok {
        shell "./dev/check-fonts.raku";
}, "checking bulk font setting";

done-testing;
