use Test;
use PDF::Content;
use PDF::Lite;
use Font::AFM;
use PDF::Document;
use FontFactory::Type1;
use FontFactory::Type1::Utils;

plan 119;

my $pdf;
my $rawfont;
my $rawafm;
my $basefont;
my $docfont;

my $up;
my $ut;
my $page;
my $size = 10;
my $x = 10;
my $y = 10;

lives-ok {
   $pdf = PDF::Lite.new;
}, "checking pdf instantiation";

for %MyFonts.keys {
    # other classes
    lives-ok {
       $basefont = find-basefont :name($_), :$pdf;
    }, "checking find-font, name: $_";
    lives-ok {
        $docfont = select-docfont :$basefont, :size(10);
    }, "checking select-docfont, name: $_, size: $size";
    lives-ok {
        $up = $docfont.UnderlinePosition;
    }, "checking font afm use for UnderlinePosition";
    lives-ok {
       $ut = $docfont.UnderlineThickness;
    }, "checking font afm use for UnderlineThickness";

    next if not $basefont.is-corefont;

    # core
    lives-ok {
        $rawfont = $pdf.core-font(:family($_));
    }, "checking raw font access, name: $_";
    lives-ok {
        $rawafm  = Font::AFM.core-font($_);
    }, "checking raw Font afm access, name: $_";
}

for %MyFontAliases.keys {
    my $A = $_.uc;
    lives-ok {
        $basefont = find-basefont :name($A), :$pdf;
    }, "checking find-font by alias, alias: $A";
    lives-ok {
        $docfont = select-docfont :$basefont, :size(10);
    }, "checking select-font by alias, : $A, size: $size";
}
