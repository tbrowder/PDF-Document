use Test;
use PDF::Content;
use PDF::Document;
use PDF::Lite;
use Font::AFM;

plan 1;

lives-ok {
    shell "./dev/check-fonts.raku";
}, "checking bulk font setting";

