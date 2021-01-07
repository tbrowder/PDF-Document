unit module PDF::Document:ver<0.0.1>:auth<cpan:TBROWDER>;

use PDF::Lite;
use Font::AFM;

# These are the "core" fonts from PostScript
# and have short names as keys
constant %CoreFonts is export = [
    Courier               => "c",
    Courier-Oblique       => "co",
    Courier-Bold          => "ch",
    Courier-BoldOblique   => "cbo",
    Helvetica             => "h",
    Helvetica-Oblique     => "ho",
    Helvetica-Bold        => "hb",
    Helvetica-BoldOblique => "hbo",
    Times-Roman           => "t",
    Times-Italic          => "ti",
    Times-Bold            => "tb",
    Times-BoldItalic      => "tbi",
    Symbol                => "s",
    Zapfdingbats          => "z",
];

our %CoreFontAliases is export = %CoreFonts.reverse;

class DocFont is export {
    has PDF::Lite $.pdf is required;
    has $.name is required; # font name
    has $.font is required;
    has $.afm is required;
}

class TextFont is export {
    has DocFont $.docfont is required;
    has Real $.size is required;
    has $.name is required; # font name
}

sub define-docfont(PDF::Lite :$pdf!, 
                   :$name!,  # full or alias
                   --> DocFont) is export {
    my $f;
    if %CoreFonts{$name}:exists {
        $f = $name;
    }
    elsif %CoreFontAliases{$name}:exists {
        $f = %CoreFontAliases{$name};
    }
    else {
        die "FATAL: Font name or alias '$name' is not recognized'";
    }
 
    my $font = $pdf.core-font(:family($f));
    my $afm  = Font::AFM.core-font($f);
    my $DF   = DocFont.new: :$pdf, :name($f), :$font, :$afm;
    return $DF;
}

sub set-docfont(DocFont :$docfont!, Real :$size! --> TextFont) is export {
    return TextFont.new: :$docfont, :name($docfont.name), :$size;
}

=finish
                   
sub load-core-fonts(:$pdf,   # a PDF::Lite class instance
                    :%fonts, # an empty hash to contain PDF::Lite font instances
                    :$debug,
                   ) is export {
    for @CoreFonts -> $f {
        my $F   = CoreFont.new: :name($f);
        $F.font = $pdf.core-font(:family($f));
        $F.afm  = Font::AFM.core-font($f) if $f !~~ /:i zapf /; # issue filed
        %fonts{$f}  = $F;
    }
    my $ne = %fonts.elems;
    die "FATAL: Font load hash does NOT contain 14 elements, it has $ne." if $ne != 14;
}
