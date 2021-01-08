use Test;
use PDF::Document;
use PDF::Lite;

plan 2; 

lives-ok {
   my $pdf = PDF::Lite.new;
   my $courier = find-font :name<c>, :$pdf;
}, "checking font alias use";

lives-ok {
        shell "./dev/check-fonts.raku";
}, "checking bulk font setting";

done-testing;
