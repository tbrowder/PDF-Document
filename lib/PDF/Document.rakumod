unit module PDF::Document:ver<0.0.2>:auth<cpan:TBROWDER>;

use PDF::Lite;

use Text::Utils :wrap-text;
use Font::AFM;
# local roles
use PDF::PDF-role;

my $debug  = 0;
my $debug2 = 1;

# Below are some convenience constants for converting various
# length units to PS points (72 per inch).
# Use them like this:
#
#   my $left-margin = 1 * in2pt; # converts 1 inch to 72 points
# British units
constant in2pt  is export = 72;            # inches
constant ft2pt  is export = 12 * in2pt;    # feet
constant yd2pt  is export = 36 * in2pt;    # yards
# SI units
constant cm2pt is export = 1/2.54 * in2pt; # centimeters
constant mm2pt is export = 0.1 * cm2pt;    # millimeters
constant dm2pt is export = 10  * cm2pt;    # decimeters
constant  m2pt is export = 100 * cm2pt;    # meters

# alternative versions
constant i2p is export = in2pt;
constant f2p is export = ft2pt;
constant y2p is export = yd2pt;
constant mm2p is export = mm2pt;
constant c2p is export = cm2pt;
constant cm2p is export = cm2pt;
constant d2p is export = dm2pt;
constant dm2p is export = dm2pt;
constant m2p is export = m2pt;

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
    method upos { self.UnderlinePosition }

    method spos {
        # define the position of the strikethrough line
        # as midheight of some character
        constant \schar = 'm';
        my ($llx, $lly, $urx, $ury) = $!afm.BBox{schar}  * $!sf;
        0.5 * ($ury - $lly);
    }
    method swid {
        # without any other source, use same as underline
        $!afm.UnderlineThickness * $!sf
    }

    #| UnderlineThickness
    method UnderlineThickness {
        $!afm.UnderlineThickness * $!sf
    }
    method uwid { self.UnderlineThickness() }

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
    # output file attrs
    has $.pdf-name = "Doc-output-default.pdf";
    has $.is-saved = False;
    has $.force    = False;
    has $.page-numbering = False;
    
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
        if $!pdf-name !~~ /:i '.pdf' $/ {
            $!pdf-name ~= '.pdf';
        }
        if $!pdf-name.IO.f {
            if not $!force {
                note qq:to/HERE/;
                FATAL: Desired output file '$!pdf-name' exists.
                       Define ':\$force' to allow overwriting existing files.
                HERE
                exit;
            }
            else {
                note qq:to/HERE/;
                WARNING: Desired output file '$!pdf-name' exists and will be over written.
                HERE
            }
        }
        $!pdf = PDF::Lite.new;
        $!pdf.media-box = 'Letter'; #$!paper;
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
        $!cpx = $!x0;
        $!cpy = $!y0;
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

    method line($x0, $y0, $x1, $y1, :$linewidth = 0) {
        self.Save;
        self.SetLineWidth($linewidth);
        self.MoveTo($x0, $y0);
        self.LineTo($x1, $y1);
        self.Stroke;
        self.Restore;
    }

    #| Starts at the current position
    method print($text,
                 # these args must resolve to cpx/cpy => :position or undefined
                 :$x is copy, :$y is copy,
                 :$tr, :$tl, :$br, :$bl,
                 # this arg must resolve to :font/:font-size or undefined
                 DocFont :$Font, # docfont
                 # these args resolve to :align keys
                 :$rj, :$lj, :$cj,
                 # these args resolve to :valign keys
                 :$ta, :$ma, :$ca,

                 # Special args that need special handling
                 # by first breaking the text into separate lines, then
                 # printing each line separately and drawing the underline
                 # and strikethrough as appropriate:
                 :$ul, # underline
                 :$st, # strikethrough

                 # expected args: add to %opt only if defined
                 # note that explicit :width needs to be specified to
                 # affect wrapping
                 :$align is copy, :$valign is copy, :$width is copy, :$height is copy,
                 :$kern, :$leading, :$nl,
                ) {

        my $font = $Font ?? $Font.font !! $!font.font;
        my $font-size = $Font ?? $Font.size !! $!font.size;
        my $font-name = $Font ?? $Font.name !! $!font.name;

        my ($cpx, $cpy);
        if    $tl { $cpx = $!x0;           $cpy = $!y0 + $!height }
        elsif $tr { $cpx = $!x0 + $!width; $cpy = $!y0 + $!height }
        elsif $bl { $cpx = $!x0;           $cpy = $!y0            }
        elsif $br { $cpx = $!x0 + $!width; $cpy = $!y0            }
        else {
            # set cpx/cpy according to :x and :y
            if $x.defined and $y.defined { $cpx = $x;    $cpy = $y    }
            elsif $x.defined             { $cpx = $x;    $cpy = $!cpy }
            elsif $y.defined             { $cpx = $!cpx; $cpy = $y    }
            else                         { $cpx = $!cpx; $cpy = $!cpy }
        }

        # :align
        if    $rj { $align = 'right'  }
        elsif $lj { $align = 'left'   }
        elsif $cj { $align = 'center' }
        # :valign
        if    $ta { $valign = 'top'    }
        elsif $ma { $valign = 'middle' }
        elsif $cj { $valign = 'center' }

        my Bool $preserve;
        # David says :position default is 0,0!!
        my List $position = [$cpx, $cpy];

        # we need an %opt hash to pass to print and
        # fill the %opt hash with defined values only
        # but NOT $position
        my %opt;
        %opt<align> = $align if $align.defined;
        %opt<valign> = $valign if $valign.defined;
        %opt<font> = $font if $font.defined;
        %opt<font-size> = $font-size if $font-size.defined;
        %opt<kern> = $kern if $kern.defined;
        %opt<leading> = $leading if $leading.defined;
        %opt<width> = $width if $width.defined;
        %opt<height> = $height if $height.defined;
        %opt<nl> = $nl if $nl.defined;

        my @curpos;
        my ($x0, $y0, $x1, $y1);
        if $ul or $st {
            # we have to treat each line indvidually
            my @lines = wrap-text $text, :$width, :$font-name, :$font-size;
            for @lines -> $line {
                # the line may be underlined or have a strikethrough line
                # position and width changes for following lines
                my $swidth = $Font.stringthwidth: $line;
                if $ul {
                    my $dy   = $Font.upos;
                    my $swid = $Font.uwid;
                    my $ys   = @curpos[1] + $dy;
                    #self.line 
                }
                if $st {
                    # strikethrough
                    my $dy   = $Font.spos;
                    my $swid = $Font.swid;
                    my $ys   = @curpos[1] + $dy;
                    #self.line 
                }
                $!page.text: -> $txt {
                    $txt.font = $font, $font-size;
                    ($x0, $y0, $x1, $y1) = $txt.print: $text, :$position, |%opt;
                    @curpos = $txt.text-position.List;
                }
            }
        }
        elsif $position.defined {
            $!page.text: -> $txt {
                $txt.font = $font, $font-size;
                ($x0, $y0, $x1, $y1) = $txt.print: $text, :$position, |%opt;
                @curpos = $txt.text-position.List;
            }
        }
        else {
            $!page.text: -> $txt {
                $txt.font = $font, $font-size;
                ($x0, $y0, $x1, $y1) = $txt.print: $text, |%opt;
                @curpos = $txt.text-position.List;
            }
        }
 
        if $debug {
            my $cap = %opt.Capture;
            note "DEBUG: Capture: {$cap.raku}";
        }

        =begin comment
        if $position.defined and not %opt.elems {
            note "DEBUG: with position, no \%opt" if $debug2;
            $!page.text: -> $txt {
                $txt.font = $font, $font-size;
                ($x0, $y0, $x1, $y1) = $txt.say($text, :$position, :$nl);
                @curpos = $txt.text-position.List;
            }
        }
        elsif $position.defined and %opt.elems  {
            note "DEBUG: with position and \%opt" if $debug2;
            $!page.text: -> $txt {
                $txt.font = $font, $font-size;
                ($x0, $y0, $x1, $y1) = $txt.say($text, :$position, |%opt);
                @curpos = $txt.text-position.List;
            }
        }
        elsif %opt.elems  {
            note "DEBUG: text with \%opt" if $debug2;
            $!page.text: -> $txt {
                $txt.font = $font, $font-size;
                ($x0, $y0, $y1, $y1) = $txt.say($text, |%opt,);
                @curpos = $txt.text-position.List;
            }
        }
        else {
            note "DEBUG: with text only" if $debug2;
            $!page.text: -> $txt {
                $txt.font = $font, $font-size;
                ($x0, $y0, $x1, $y1) = $txt.say($text);
                @curpos = $txt.text-position.List;
            }
        }
        =end comment

        #if $debug {
        if 1 {
            # draw a box outlining the text bounding box
            self.Save; 
            self.SetLineWidth(0);
            self.MoveTo($x0, $y0); 
            self.LineTo($x1, $y0);
            self.LineTo($x1, $y1);
            self.LineTo($x0, $y1);
            self.ClosePath;
            self.Stroke;
            self.Restore;
            # draw an "x" at the curpos

            my $xc = @curpos[0];
            my $yc = @curpos[1];
            my $r  = 30;
            self.Save; 
            self.MoveTo($xc+$r, $yc+$r); 
            self.LineTo($xc-$r, $yc-$r); 
            self.MoveTo($xc-$r, $yc+$r); 
            self.LineTo($xc+$r, $yc-$r); 
            self.Stroke;
            self.Restore;
        }

        if 1 {
            note "DEBUG: text bbox: [$x0, $y0, $x1, $y1]; curpos = {@curpos.raku}";
            #note "early exit";
            #exit
        }

        # reset cpx, cpy
        # TODO adjust cpx for word spacing, cpy should be the baseline of the last line
        if $nl {
            $!cpx = $!x0;
        }
        else {
            $!cpx = $x1;
        }
        $!cpy = $y0;
    }

    method say($text, *%opt) {
        # calls method print with :nl (newline) true
        %opt<nl> = True;
        self.print: $text, |%opt;
    }

    # convenience methods
    # use the current page and cpx/cpy
    multi method mvto($x, $y) {
        #self.MoveTo($x, $y);
        #$!page.text.text-position = $x, $y; # self.MoveTo($x, $y);
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

        #self.MoveTo($x, $y);
        #$!page.gfx.text-position = $x, $y; # self.MoveTo($x, $y);
        # reset cpx/cpy
        $!cpx = $x;
        $!cpy = $y;
    }
    method rmvto($delta-x, $delta-y) is export {
        my $x = $!cpx + $delta-x;
        my $y = $!cpy + $delta-y;
        #self.MoveTo($x, $y);
        # reset cpx/cpy
        $!cpx = $x;
        $!cpy = $y;
    }
    method nl($n = 1) is export {
        # moves cpy down by n lines, resets cx=0
        die "no cpy" if not $!cpy.defined;
        my $delta-y = $n * $!leading;
        my $x = $!x0;
        my $y = $!cpy - $delta-y;
        #self.MoveTo($x, $y);
        # reset cpx/cpy
        $!cpx = $x;
        $!cpy = $y;
    }
    method np() is export {
        $!page = $!pdf.add-page
    }

    method end-doc($file-name?) is export {
        return if not (self or $!pdf);
        self.number-pages if $!page-numbering;
        my $fname = $file-name.defined ?? $file-name !! $!pdf-name;
        if not $!is-saved {
            $!pdf.save-as: $fname;
            $!is-saved = True;
        }
        note "See output file: '$fname'";
    }

    method number-pages() {
        my $npages = self.pdf.page-count;
        for 1 .. $npages -> $n {
            self.page = self.pdf.page: $n;
        }
    }
    method setlinewidth($width where { $_ >= 0 }) {
        self.SetLineWidth: $width;
    }
    method setgray($level where {0 <= $_ <= 1}) {
    }
    method setrgb($r where {0 <= $_ <= 1}, 
                  $g where {0 <= $_ <= 1}, 
                  $b where {0 <= $_ <= 1},
                 ) {
    }
    method save() {
        self.Save;
    }
    method restore() {
        self.Restore;
    }

    sub value2points($val is copy) {
        if $val ~~ /:i ^ (<[\d.+-]>+) ([in|cm|mm|ft])? \N* $/ {
            $val = +$0;
            return $val if not $1.defined;
            my $units = ~$1;
            given $units {
                when $_ eq 'in' { $val *= in2pt }
                when $_ eq 'cm' { $val *= cm2pt }
                when $_ eq 'mm' { $val *= mm2pt }
                when $_ eq 'ft' { $val *= ft2pt }
                default { 
                    die "FATAL: Unknown units in input value '$val'";
                }
            }
        }
        return $val;
    }

    multi method ellipse(:$x, :$y, :$a, :$b) {
        my $cx = value2points $x;
        my $cy = value2points $y;
        my $ca = value2points $a;
        my $cb = value2points $b;
        self.ellipse($cx, $cy, $ca, $cb); 
    }
    multi method ellipse($x, $y, $a, $b, :$fill = False) {
        self.Save;
        self.MoveTo: $x, $y;
        # define x1/y1, x2/y2, and x3/y3 as bezier control points with new cp at x3/y3
        # for an ellipse we can do that with two semiellipses:
        #   work counterclockwise      
        self.MoveTo:  $x + $a, $y;       # start at the right, angle of zero degrees
        self.CurveTo: $x + $a, $y + $b,  # upper right
                      $x - $a, $y + $b,  # upper left
                      $x - $a, $y;       # left
        self.CurveTo: $x - $a, $y - $b,  # lower left
                      $x + $a, $y - $b,  # lower right
                      $x - $a, $y;       # back to the right
        self.ClosePath;
        if $fill { self.Fill; }
        else { self.Stroke; }
        self.Restore;
    }

    multi method rectangle(:$llx, :$lly, :$width, :$height, :$fill = False) {
        my $x = value2points $llx;
        my $y = value2points $lly;
        my $w = value2points $width;
        my $h = value2points $height;
        self.rectangle($x, $, $w, $h, :$fill);
    }
    multi method rectangle($llx, $lly, $width, $height, :$fill = False) {
        self.Save;
        self.Rectangle: $llx, $lly, $width, $height;
        if $fill { self.Fill; }
        else { self.Stroke; }
        self.Restore;
    }

    multi method circle(:$x, :$y, :$radius, :$fill = False) {
        my $cx = value2points $x;
        my $cy = value2points $y;
        my $cr = value2points $radius;
        self.circle($cx, $cy, $cr); 
    }
    multi method circle($x, $y, $r, :$fill = False) {
        self.Save;
        self.MoveTo: $x, $y;
        # define x1/y1, x2/y2, and x3/y3 as bezier control points with new cp at x3/y3
        # for a circle we can do that with two semicircles:
        #   work counterclockwise      
        self.MoveTo:  $x + $r, $y;       # start at the right, angle of zero degrees
        self.CurveTo: $x + $r, $y + $r,  # upper right
                      $x - $r, $y + $r,  # upper left
                      $x - $r, $y;       # left
        self.CurveTo: $x - $r, $y - $r,  # lower left
                      $x + $r, $y - $r,  # lower right
                      $x - $r, $y;       # back to the right
        self.ClosePath;
        if $fill { self.Fill; }
        else { self.Stroke; }
        self.Restore;
    }

    # Many other methods are provided by roles "PDF-role"
    # and "AFM-role".
    # Note those roles are auto-generated by program
    # dev/generate-code.raku.
}
