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

sub show-corefonts is export {
    my $max = 0;
    for %CoreFonts.keys -> $k {
        my $n = $k.chars;
        $max = $n if $n > $max;
    }

    ++$max; # make room for closing '
    for %CoreFonts.keys.sort -> $k {
        my $v = %CoreFonts{$k};
        my $f = $k ~ "'";
        say sprintf("Font family: '%-*.*s (alias: '$v')", $max, $max, $f);
    }
}

class FontFamily is export {
    has PDF::Lite $.pdf is required;
    has $.name is required; # font name
    has $.font is required;
    has $.afm is required;
}

class DocFont is export {
    has FontFamily $.fontfamily is required;
    has Real $.size is required;
    has $.name is required; # font name
}

sub find-font(PDF::Lite :$pdf!, 
              :$name!,  # full or alias
              --> FontFamily) is export {
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
    my $FF   = FontFamily.new: :$pdf, :name($f), :$font, :$afm;
    return $FF;
}

sub select-font(FontFamily :$fontfamily!, 
                Real :$size! 
                --> DocFont) is export {
    return DocFont.new: :$fontfamily, :name($fontfamily.name), :$size;
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
