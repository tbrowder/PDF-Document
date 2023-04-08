use Test;
use PDF::Content;
use PDF::Document;
use PDF::Lite;
use Font::AFM;
use Proc::Easier;

plan 1;

lives-ok {
    my $args = "./dev/check-fonts.raku";
    my $cmd  = cmd $args, :die;
}, "checking bulk font setting";

