use Test;
use PDF::Content;
use PDF::Document;
use PDF::Lite;
use Font::AFM;

plan 1;

my $doc;
lives-ok {
    $doc = Doc.new: :media-box('Letter');
}, "checking new Doc object";

