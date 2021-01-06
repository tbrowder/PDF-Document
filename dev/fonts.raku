#!/usr/bin/env raku

use lib <./lib ../lib>;
use PDF::Document;
use PDF::Lite;
use Font::AFM;

if 1 {
    say "Standard fonts:";
    say "  $_" for @Fonts;
}

# test with a pdf doc
my $pdf = PDF::Lite.new;
$pdf.media-box = 'Letter';
my $page = $pdf.add-page();
my $font;
my $afm;
for @Fonts -> $f {
    given $f.lc {
        say "Getting PDF font: $_";
        $afm = Font::AFM.new(:name($f)) if $_ !~~ /:i zapf /; # issue filed
        when $_ eq 'courier' {
            $font = $page.core-font(:family<Courier>);
        }
        when $_ eq 'courier-bold' {
            $font = $page.core-font(:family<Courier-Bold>);
        }
        when $_ eq 'courier-oblique' {
            $font = $page.core-font(:family<Courier-Oblique>);
        }
        when $_ eq 'courier-boldoblique' {
            $font = $page.core-font(:family<Courier-BoldOblique>);
        }
        when $_ eq 'helvetica' {
            $font = $page.core-font(:family<Helvetica>);
        }
        when $_ eq 'helvetica-bold' {
            $font = $page.core-font(:family<Helvetica-Bold>);
        }
        when $_ eq 'helvetica-oblique' {
            $font = $page.core-font(:family<Helvetica-Oblique>);
        }
        when $_ eq 'helvetica-boldoblique' {
            $font = $page.core-font(:family<Helvetica-BoldOblique>);
        }
        when $_ eq 'times-roman' {
            $font = $page.core-font(:family<Times-Roman>);
        }
        when $_ eq 'times-bold' {
            $font = $page.core-font(:family<Times-Bold>);
        }
        when $_ eq 'times-italic' {
            $font = $page.core-font(:family<Times-Italic>);
        }
        when $_ eq 'times-bolditalic' {
            $font = $page.core-font(:family<Times>);
        }
        when $_ eq 'symbol' {
            $font = $page.core-font(:family<Symbol>);
        }
        when $_ eq 'zapfdingbats' {
            $font = $page.core-font(:family<Zapfdingbats>);
        }
        default {
            die "FATAL: Font name '$f' not known.";
        }
    }
}
