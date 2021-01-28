use Test;
use PDF::Content;
use PDF::Document;
use PDF::Lite;
use Font::AFM;

plan 3;

my $doc;
lives-ok {
    $doc = Doc.new: :media-box('Letter');
}, "checking new Doc object";

lives-ok {
    shell "./dev/make-example-doc.raku";
}, "testing the example doc with no args";

lives-ok {
    shell "./dev/make-example-doc.raku g";
}, "testing the example doc with arg of 'g'";


