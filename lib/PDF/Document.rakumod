unit module PDF::Document:ver<0.0.2>:auth<cpan:TBROWDER>;

use PDF::Lite;
use Font::AFM;
# local roles
use PDF::PDF-role;

# Below are some convenience constants for converting various
# length units to PS points (72 per inch).
# Use them like this:
#
#   my $left-margin = 1 * i2p; # converts 1 inch to 72 points
# British units
constant i2p  is export = 72;           # inches
constant f2p  is export = 12 * i2p;     # feet
# SI units
constant cm2p is export = 1/2.54 * i2p; # centimeters
constant mm2p is export = 0.1 * cm2p;   # millimeters

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

our %CoreFontAliases is export = %CoreFonts.invert;

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

class BaseFont is export {
    has PDF::Lite $.pdf is required;
    has $.name is required;    #= the recognized font name
    has $.rawfont is required; #= the font object from PDF::Lite
    has $.rawafm is required;  #= the afm object from Font::AFM
}

sub find-basefont(PDF::Lite :$pdf!,
                  :$name!,  # full or alias
                  --> BaseFont) is export {
    my $fnam; # to hold the recognized font name
    if %CoreFonts{$name}:exists {
        $fnam = $name;
    }
    elsif %CoreFontAliases{$name.lc}:exists {
        $fnam = %CoreFontAliases{$name.lc};
    }
    else {
        die "FATAL: Font name or alias '$name' is not recognized'";
    }

    my $rawfont = $pdf.core-font(:family($fnam));
    my $rawafm  = Font::AFM.core-font($fnam);
    my $BF      = BaseFont.new: :$pdf, :name($fnam), :$rawfont, :$rawafm;
    return $BF;
}

class DocFont is export {
    has BaseFont $.basefont is required;
    has $.name is required; # font name
    has Real $.size is required;
    # convenience attrs
    has $.afm;  #= the the Font::AFM object
    has $.font; #= the PDF::Lite font object
    has $!sf;   #= scale factor for the afm attrs vs the font size

    submethod TWEAK {
        $!sf = $!size / 1000;
    }

    # Convenience methods (and aliases) from the afm object and size.
    # See Font::AFM for details.

    #| UnderlinePosition
    method UnderlinePosition {
        $!afm.UnderlinePosition * $!sf
    }
    method up { self.UnderlinePosition }

    #| UnderlineThickness
    method UnderlineThickness {
        $!afm.UnderlineThickness * $!sf
    }
    method ut { self.UnderlineThickness() }

    # ($kerned, $width) = $afm.kern($string, $fontsize?, :%glyphs?)
    # Kern the string. Returns an array of string segments, separated
    # by numeric kerning distances, and the overall width of the string.
    method kern($string, $fontsize?, :%glyphs?) {
    }

    # A two dimensional hash containing from and to glyphs and kerning widths.
    method KernData {
        $!afm.KernData
    }

    # $afm.stringwidth($string, $fontsize?, :$kern, :%glyphs)
    #| stringwidth
    method stringwidth($string, :$kern, :%glyphs) {
        $!afm.stringwidth: $string, $!size, :$kern, :%glyphs
    }
    method sw($string, :$kern, :%glyphs) { stringwidth: $string, :$kern, :%glyphs }

    method IsFixedPitch {
        $!afm.IsFixedPitch
    }

    # other methods
    method FontName {
        $!afm.FontName
    }
    method FullName {}
    method FamilyName {}
    method Weight {}
    method ItalicAngle {}
    method FontBBox {}
    method Version {}
    method Notice {}
    method Comment {}
    method EncodingScheme {}
    method CapHeight {}
    method XHeight {}
    method Ascender {}
    method Descender {}
    method Wx {}
    method BBox {}
    =begin comment
    method ? {}
    method ? {}
    method ? {}
    method ? {}
    =end comment
}

sub select-docfont(BaseFont :$basefont!,
                   Real :$size!
                   --> DocFont) is export {
    my $df = DocFont.new: :$basefont, :name($basefont.name), :font($basefont.rawfont),
                          :afm($basefont.rawafm), :$size;
    return $df;
}

class FontFactory is export {
    has $.pdf is required;

    # hash of BaseFonts keyed by their alias name
    has %.basefonts;
    # hash of DocFonts keyed by an alias name which includes the font's size
    has %.docfonts;

    method get-font($name) {
        # "name" is a key in a specific format
        my $key;

        # pieces required to get the docfont
        my $alias;
        my $size;

        # pieces of the size
        my $sizint;
        my $sizfrac;
        # examples of valid names:
        #   t12, t2d3, cbo10, ho12d5
        if $name ~~ /^ (<[A..Za..z-]>+) (\d+)  ['d' (\d+)]? $/ {
            $alias   = ~$0;
            $sizint  = ~$1;

            $key  = $alias ~ $sizint;
            $size = $sizint;

            # optional decimal fraction
            $sizfrac = ~$2 if $2.defined;
            if $sizfrac.defined {
                $key  ~= 'd' ~ $sizfrac;
                $size ~= '.' ~ $sizfrac;
            }
            $size .= Real;
        }
        else {
            note "FATAL: You entered the desired font name '$name'.";
            die q:to/HERE/;
            The desired font name must be in the format "<name><size>"
            where "<name>" is a valid font name or alias and "<size>"
            is either an integral number or a decimal number in
            the form "\d+d\d+" (e.g., '12d5' which mean '12.5' PS points).
            HERE
        }
        # if we have the docfont return it
        if %!docfonts{$key}:exists {
            return %!docfonts{$key};
        }
        elsif %!basefonts{$alias}:exists {
            # do we have the basefont?
            my $basefont = %!basefonts{$alias};
            my $docfont = select-docfont :$basefont, :$size;
            %!docfonts{$key} = $docfont;
            return %!docfonts{$key};
        }
        else {
            # we need the whole banana
            my $basefont = find-basefont :pdf($!pdf), :name($alias);
            %!basefonts{$alias} = $basefont;
            my $docfont = select-docfont :$basefont, :$size;
            %!docfonts{$key} = $docfont;
            return %!docfonts{$key};
        }
    }
}

# the big kahuna: it should have all major methods and attrs from lower levels at this level
class Doc does PDF-role is export {
    has $.paper;
    has $.media-box = 'Letter'; # = is required;

    has $.leading; #= linespacing
    has $.linespacing;
    has $.leading-ratio = 1.3; #= leading/fontsize

    # the current page params
    # origin
    has $.x0 = 0;
    has $.y0 = 0;
    # currentpoint
    has $.cpx = 0;
    has $.cpy = 0;
    # margins
    has $.lm = 0;
    has $.rm = 0;
    has $.tm = 0;
    has $.bm = 0;
    # page metrics
    has $.pwidth  = 0;
    has $.pheight = 0;
    # print area metrics
    has $.width  = 0;
    has $.height = 0;

    # set by TWEAK
    # has $.pdf;  # in PDF-role
    # has $.page; # in PDF-role
    has FontFactory $.ff;
    has DocFont $.font;

    submethod TWEAK {
        $!media-box = $!paper;
        $!pdf = PDF::Lite.new;
        $!page = $!pdf.add-page;
        $!ff  = FontFactory.new: :pdf($!pdf);
        $!font = $!ff.get-font: 't12'; # Times-Roman 12
        $!leading = $!font.size * $!leading-ratio;
        $!linespacing = $!leading;
        # set default margins
        $!lm = 72;
        $!rm = 72;
        $!tm = 72;
        $!bm = 72;
        # other page metrics
        $!pwidth  = 8.5 * i2p;
        $!pheight = 11 * i2p;
        $!width   = $!pwidth  - $!lm - $!rm;
        $!height  = $!pheight - $!tm - $!bm;
        $!x0 = $!lm;
        $!y0 = $!bm;
    }

    method set-font($alias) {
        $!font = $!ff.get-font($alias)
    }
    method add-page() {
        $!page = $!pdf.add-page;
    }
    method set-margins(:$left, :$right, :$top, :$bottom) {
        $!lm = $left if $left;
        $!rm = $right if $right;
        $!tm = $top if $top;
        $!bm = $bottom if $bottom;
    }

    # text subs

    # private
    method !choose-font($fontalias) {
        my $font; # rawfont
        my Real $size;
        if $fontalias.defined {
            my $df = $!ff.get-font: $fontalias;
            $font = $df.font;
            $size = $df.size;
        }
        else {
            $font = $!font.font;
            $size = $!font.size;
        }
        return ($font, $size);
    }

    # text
    =begin comment
    multi text(Real $x, Real $y, $string, :$fontalias, :%extra) {
        self.text($string, :$x, :$y, :$fontalias, :%extra)
    }
    =end comment

    method text($string, :$x, :$y, :$fontalias,
        :$j, # justify: l (default), c, r
        :$kern = True, # False for Courier
        :$box,
        # room for more tuning and embellishment here:
        :%extra,
        ) {

        my ($font, $size) = self!choose-font($fontalias);
        # At this point we may need some fancy handling
        # which we determine by whether there are any
        # %extra elements.
        my $use-xy = ($x.defined and $y.defined) ?? True !! False;


        if %extra.elems {
            # assuming a line of text, no para, no filling or line wrapping

            # unless we are using fixed-width fonts (e.g., Courier), we WILL
            # use kerning

            # for underlining, we need to know the width of the text, and
            # the thickness and position of the underlining and then
            # add the underline

            my $sw;
            if $font.afm.IsFixedPitch {
                # get the width of the string without kerning
                $sw = $font.afm.stringwidth: $string, $size;
            }
            else {
                # get the width of the string with kerning
                $sw = $font.afm.stringwidth: $string, $size, :kern;
            }
        }
        if $x.defined and $y.defined {
            $!page.text: { .text-position = $x, $y; .font = $font, $size; .say($string); }
        }
        else {
            $!page.text: { .font = $font, $size; .say($string); }
        }
    }

    #| Starts at the current position
    method print($string,
                 :$align,
                 :$valign,
                 :$Font, # docfont
                 :$kern,
                 :$leading,
                 :$width,
                 :$height,
                 :$nl,
                ) {
        my $font = $Font.font;
        my $font-size = $Font.size;
        $!page.gfx.print(
                         :$align,
                         :$valign,
                         :$font, # rawfont
                         :$font-size,
                         :$kern,
                         :$leading,
                         :$width,
                         :$height,
                         :$nl,
                        );
    }

    # convenience methods
    # use the current page and cpx/cpy
    multi method mvto($x, $y) {
        self.MoveTo($x, $y);
        # reset cpx/cpy
        $!cpx = $x;
        $!cpy = $y;
    }
    multi method mvto(:$tl, :$tr, :$bl, :$br, :$abs = False) {
        my ($x, $y);
        if    $tl { $x = $!x0;           $y = $!y0 + $!height }
        elsif $tr { $x = $!x0 + $!width; $y = $!y0 + $!height }
        elsif $bl { $x = $!x0;           $y = $!y0 }
        elsif $br { $x = $!x0 + $!width; $y = $!y0 }
        else      { return }

        self.MoveTo($x, $y);
        # reset cpx/cpy
        $!cpx = $x;
        $!cpy = $y;
    }
    method rmvto($delta-x, $delta-y) is export {
        my $x = $!cpx + $delta-x;
        my $y = $!cpy + $delta-y;
        self.MoveTo($x, $y);
        # reset cpx/cpy
        $!cpx = $x;
        $!cpy = $y;
    }
    method nl($n = 1) is export {
        # moves cpy down by n lines, resets cx=0
        my $delta-y = $n * $!leading;
        my $x = $!x0;
        my $y = $!cpy - $delta-y;
        self.MoveTo($x, $y);
        # reset cpx/cpy
        $!cpx = $x;
        $!cpy = $y;
    }
    method np() is export {
        $!page = $!pdf.add-page
    }
    method save($file-name) is export {
        $!pdf.save-as: $file-name
    }

    # Many other methods are provided by roles "PDF-role"
    # and "AFM-role".
    # Note those roles are auto-generated by program
    # dev/generate-code.raku.
}
