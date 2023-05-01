use Test;
use PDF::Content;
use PDF::Lite;
use Font::AFM;
use Proc::Easier;
use PDF::Document;
#use PDF::FontFactory;

plan 1;

lives-ok {
    my $args = "./dev/bin/check-fonts.raku";
    my $cmd  = cmd $args;
}, "checking bulk font setting";

