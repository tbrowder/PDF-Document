#!/usr/bin/env raku

use lib <./lib ../lib>;
use PDF::Document;
use PDF::Lite;
use Font::AFM;

# NOTE: All measurements in AFM files are given in terms of units
# equal to 1/1000 of the scale factor of the font being used. To
# compute actual sizes in a document, these amounts should be
# multiplied by (scale factor of font)/1000.

# test with a pdf doc
my $pdf = PDF::Lite.new;
my $bf = find-basefont :$pdf, :name<ti>;
my $df = select-docfont :basefont($bf), :size(10);
my $afm = Font::AFM.new: :name<Times-Italic>;


# Returns the width of the string passed as argument. The string is
# assumed to contains only characters from %glyphs. A second argument
# can be used to scale the width according to the font size.
#
# $afm.stringwidth($string, $fontsize?, :kern, :%glyphs);
say "width of Gisle at 10 pts: ", $afm.stringwidth("Gisle", 10);

# Kern the string. Returns an array of string segments, separated by
# numeric kerning distances, and the overall width of the string.
#
# ($kerned, $width) = $afm.kern($string, $fontsize?, :%glyphs?)
my $txt = "You know soap foam is bubbly and bad tasting.";

my ($kerned, $width) = $afm.kern($txt, 10);
say "Kerning '$txt'";
for ($kerned, $width) -> $k, $w {
    say "chars: '$k', width: $w";
}

say "Early exit before afm data..."; exit;

say $afm.FontName;
say $afm.FullName;
say $afm.FamilyName;
say $afm.Weight;
say $afm.ItalicAngle;
say $afm.IsFixedPitch;
say $afm.FontBBox;
say $afm.KernData;
say $afm.UnderlinePosition;
say $afm.UnderlineThickness;
say $afm.Version;
say $afm.Notice;
say $afm.Comment;
say $afm.CapHeight;
say $afm.XHeight;
say $afm.Ascender;
say $afm.Descender;
say $afm.Wx;

say "Early exit before BBox hash..."; exit;

# Returns a hash table that maps from glyph names to bounding box
# information. The bounding box consist of four numbers: llx, lly,
# urx, ury.
say $afm.BBox;
