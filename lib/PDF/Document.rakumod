unit module PDF::Document;

use MacOS::NativeLib "*";
use PDF::Lite;
use PDF::Content::Page :PageSizes, :&to-landscape;

use Text::Utils :wrap-text;
use Font::AFM;

# local roles
use PDF::Document::Role;

my $debug  = 0;
my $debug2 = 1;

# for angle conversions
#--------------------------------
# 2 pi rad = 360 degrees
# rad = 360 deg / 2 pi = 180 / pi => rad/deg => rad2deg
constant rad2deg is export = 180/pi;
#--------------------------------
# 360 deg = 2 pi rad
# deg = 2 pi rad / 360 = pi / 180 => deg/rad => deg2rad
constant deg2rad is export = pi/180;
#--------------------------------

# Below are some convenience constants for converting various
# length units to PS points (72 per inch).
# Use them like this:
#
#   my $left-margin = 1 * in2pt; # converts 1 inch to 72 points
#
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
constant  i2p is export = in2pt;
constant  f2p is export = ft2pt;
constant  y2p is export = yd2pt;
constant mm2p is export = mm2pt;
constant  c2p is export = cm2pt;
constant cm2p is export = cm2pt;
constant  d2p is export = dm2pt;
constant dm2p is export = dm2pt;
constant  m2p is export =  m2pt;

#| copied from PDF::Content
my subset Box of List is export where {.elems == 4}
#| e.g. $.to-landscape(PagesSizes::A4)
#sub to-landscape(Box $p --> Box) is export {
#    [ $p[1], $p[0], $p[3], $p[2] ]
#}

# convenience methods for the page media-box
class Point is export {
    has $.x is required;
    has $.y is required;

    multi method new($x, $y) {
        return self.bless(:$x, :$y)
    }
}

# changing to a class
class DocBox is export {
    has $.llx = 0;
    has $.lly = 0;
    has $.urx is required;
    has $.ury is required;
    has $.landscape = False;

    submethod TWEAK {
        die "DocBox: llx must be >= 0" unless $!llx >= 0;
        die "DocBox: lly must be >= 0" unless $!lly >= 0;
        die "DocBox: llx must be < urx" unless $!urx > $!llx;
        die "DocBox: lly must be < ury" unless $!ury > $!lly;
    }

    multi method new(Point $ll, Point $ur) {
        return self.bless(:llx($ll.x), :lly($ll.y), :urx($ur.x), :ury($ur.y))
    }

    multi method new($urx, $ury) {
        return self.bless(:$urx, :$ury)
    }

    multi method new($llx, $lly, $urx, $ury) {
        return self.bless(:$llx, :$lly, :$urx, :$ury)
    }

    multi method new(Box $p) {
        return self.bless(:llx($p[0]), :lly($p[1]), :urx($p[2]), :ury($p[3]))
	#[ $p[1], $p[0], $p[3], $p[2] ]
    }

    method lx { self.llx }
    method ly { self.lly }
    method ux { self.urx }
    method uy { self.ury }

    method cx {
        0.5 * ($!urx - $!llx)
    }
    method ctrx { self.cx }

    method cy {
        0.5 * ($!ury - $!lly)
    }
    method ctry { self.cy }

    method w {
        $!urx - $!llx
    }
    method width { self.w }

    method h {
        $!ury - $!lly
    }
    method height { self.h }

    # other fracs
    method fx($f where {0 <= $_ <= 1}) {
        self.width * $f
    }
    method fracx($f) { self.fx: $f }

    method fy($f where {0 <= $_ <= 1}) {
        self.height * $f
    }
    method fracy($f) { self.fy: $f }

    # fancier methods
    method shrink($v where { 0 < $_ }) {
        # new llx and lly cannot be < 0
        # new width and height cannot be < 0
        my ($llx, $lly, $urx, $ury) = $!llx, $!lly, $!urx, $!ury;
        my $nw = self.w - 2*$v;
        my $nh = self.h - 2*$v;
        die "DocBox shrink: width must be > 0" unless $nw > 0;
        die "DocBox shrink: height must be > 0" unless $nh > 0;

        $llx += $v;
        $lly += $v;
        $urx -= $v;
        $ury -= $v;
        die "DocBox shrink: llx must be >= 0" unless $llx >= 0;
        die "DocBox shrink: lly must be >= 0" unless $lly >= 0;

        ($!llx, $!lly, $!urx, $!ury) = $llx, $lly, $urx, $ury;
    }
    method expand($v where { 0 < $_ }) {
        # new llx and lly cannot be < 0
        # new llx and lly cannot be < 0
        # new width and height cannot be < 0
        my ($llx, $lly, $urx, $ury) = $!llx, $!lly, $!urx, $!ury;
        my $nw = self.w - 2*$v;
        my $nh = self.h - 2*$v;
        die "DocBox shrink: width must be > 0" unless $nw > 0;
        die "DocBox shrink: height must be > 0" unless $nh > 0;

        $llx -= $v;
        $lly -= $v;
        $urx += $v;
        $ury += $v;

        die "DocBox shrink: llx must be >= 0" unless $llx >= 0;
        die "DocBox shrink: lly must be >= 0" unless $lly >= 0;

        ($!llx, $!lly, $!urx, $!ury) = $llx, $lly, $urx, $ury;
    }

    method to-portrait {
        return if not $!landscape;
	#[ $p[1], $p[0], $p[3], $p[2] ]
        # save current points
        my ($llx, $lly, $urx, $ury) = $!llx, $!lly, $!urx, $!ury;
        # transform
        ($!llx, $!lly, $!urx, $!ury) = $lly, $llx, $ury, $urx;
        $!landscape = False;
    }
    method to-landscape {
        return if $!landscape;
	#[ $p[1], $p[0], $p[3], $p[2] ]
        # save current points
        my ($llx, $lly, $urx, $ury) = $!llx, $!lly, $!urx, $!ury;
        # transform
        ($!llx, $!lly, $!urx, $!ury) = $lly, $llx, $ury, $urx;
        $!landscape = True;
    }
}

# The big kahuna: it should have all major methods and attrs from
# lower levels at this level
class Doc does PDF::Document::Role is export {
    use FontFactory::Type1;
    use FontFactory::Type1::Subs;

    # output file attrs
    has $.pdf-name = "Doc-output-default.pdf";
    has $.is-saved = False;
    has $.force    = False;
    has $.page-numbering = False;

    has $.media     = 'Letter'; # default
    has $.media-box; # = [0, 0, 500, 500] = 'Letter'; # default

    has $.leading; #= linespacing
    has $.linespacing;
    has $.leading-ratio = 1.3; #= leading/fontsize

    # miscellaneous
    has $.debug = 0;
    has $.debug-bbox = 0;

    # the current page params
    # from page.media-box
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
    #has $.pdf;  # in PDF-role
    #has $.page; # in PDF-role
    #has FontFactory $.ff;
    has $.ff;
    #has FontFactory::DocFont $.font;
    has $.font;

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
                WARNING: Desired output file '$!pdf-name' exists and will be 
                         over written.
                HERE
            }
        }
        $!pdf = PDF::Lite.new;

        #$!pdf.media-box = $!media-box; # default: 'Letter'; #$!paper;
        # DON'T START WITH A CURRENT PAGE
        #$!page = $!pdf.add-page;

        $!ff  = FontFactory::Type1.new: :pdf($!pdf);
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
        # set my current point
        $!cpx = $!x0;
        #$!cpy = $!pheight - $!tm - $!font.first-line-height; #$!y0;
        $!cpy = $!pheight - $!tm;# - $!font.first-line-height; #$!y0;
    }

    method set-font($alias) {
        $!font = $!ff.get-font($alias)
    }
    method add-page() {
        $!page = $!pdf.add-page;
        # DO NOT SET MEDIA BOX HERE YET
        #$!page.media-box = 'A4'; []; #$!pdf.media-box;
        # set my current point
        $!cpx = $!x0;
        #$!cpy = $!pheight - $!tm - $!font.first-line-height; #$!y0;
        $!cpy = $!pheight - $!tm; # - $!font.first-line-height; #$!y0;
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

    method scale($sx, $sy) {
        # Scaling: sx 0 0 sy 0 0
        self.cm($sx, 0, 0, $sy, 0, 0);
    }

    method rotate($radians) {
            self.page.gfx.transform: :rotate($radians);
    }
    method translate($x, $y) {
        # Translation: 1 0 0 1 tx ty
        self.page.gfx.transform: :translate[$x,$y];
        #self.cm(1, 0, 0, 1, $x, $y);
    }

    multi method line(List $from, :$length!, :$angle!,
        :$color = [0], # black
        :$linewidth = 0
        ) {
        my $x0  = self!value2points: $from.head;
        my $y0  = self!value2points: $from.tail;
        my $len = self!value2points: $length;
        my $ang = self!value2radians: $angle; # convert to default radians if need be
        my $x1  = $x0 + $ang.cos * $len;
        my $y1  = $y0 + $ang.sin * $len;
        self.line: $x0, $y0, $x1, $y1, :$linewidth, :$color;
    }
    multi method line(List $from, List $to,
        :$color = [0], # black
        :$linewidth = 0
        ) {
        my $x0 = self!value2points: $from.head;
        my $y0 = self!value2points: $from.tail;
        my $x1 = self!value2points: $to.head;
        my $y1 = self!value2points: $to.tail;
        self.line: $x0, $y0, $x1, $y1, :$linewidth, :$color;
    }
    multi method line(Real $x0, Real $y0, Real $x1, Real $y1,
        :$color = [0], # black
        :$linewidth = 0
        ) {
        self.Save;
        self.setlinewidth: $linewidth, :$color;
        self.MoveTo: $x0, $y0;
        self.LineTo: $x1, $y1;
        self.Stroke;
        self.Restore;
    }

    #| Starts at the current position
    method print($text,
                 # these args must resolve to cpx/cpy => :position or undefined
                 :$x is copy, :$y is copy,
                 :$tr, :$tl, :$br, :$bl,
                 # this arg must resolve to :font/:font-size or undefined
                 #FontFactory::Type1::DocFont :$Font, # docfont
                 :$Font, # docfont

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
            if $x.defined and $y.defined {
                $cpx = self!value2points: $x;
                $cpy = self!value2points: $y;
            }
            elsif $x.defined {
                $cpx = self!value2points: $x;
                $cpy = $!cpy;
            }
            elsif $y.defined {
                $cpx = $!cpx;
                $cpy = self!value2points: $y;
            }
            else {
                $cpx = $!cpx;
                $cpy = $!cpy;
            }
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

        if $width.defined {
            %opt<width> = $width;
        }
        else {
            %opt<width> = $!width;
        }

        %opt<height> = $height if $height.defined;
        %opt<nl> = $nl if $nl.defined;

        my $label  = $nl ?? 'nl' !! 'no nl';
        my $label2 = '';
        my @curpos;
        my ($x0, $y0, $x1, $y1);
        if $ul or $st {
            # we have to treat each line indvidually
            # calling sub in Text::Utils:
            my @lines = wrap-text $text, :$width, :$font-name, :$font-size;
            for @lines -> $line {
                # the line may be underlined or have a strikethrough line
                # position and width changes for following lines
                my $swidth = $Font.stringthwidth: $line;
                if $ul {
                    $label2 = 'ul';
                    # underline
                    # Note one source says the underline position for a
                    # font is the TOP of the stroke so the actual
                    # position should be adjusted for the underline
                    # thickness.
                    my $xx  = @curpos[0];
                    my $dy  = $Font.upos;
                    my $thk = $Font.uthk;
                    my $yy  = @curpos[1] + $dy;
                    self.line: $xx, $yy, $xx + $swidth, $yy, :linethickness($thk);
                }
                if $st {
                    $label2 = $label2 ?? $label2 ~ '&st' !! 'st';
                    # strikethrough
                    my $xx  = @curpos[0];
                    my $dy  = $Font.spos;
                    my $thk = $Font.sthk;
                    my $yy  = @curpos[1] + $dy;
                    self.line: $xx, $yy, $xx + $swidth, $yy, :linethickness($thk);
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

        =begin comment
        if $debug {
            my $cap = %opt.Capture;
            note "DEBUG: Capture: {$cap.raku}";
        }
        =end comment

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
        if self.debug {
            # draw a box outlining the text bounding box
            self!draw-rectangle: $x0, $y0, $x1, $y1;
            # draw an "x" at the curpos
            my $xc = @curpos[0];
            my $yc = @curpos[1];
            my $r  = 20;
            self.line: $xc+$r, $yc+$r, $xc-$r, $yc-$r;
            self.line: $xc-$r, $yc+$r, $xc+$r, $yc-$r;
        }

        if self.debug {
            my $lab = $label2 ?? "$label; $label2" !! $label;
            note "DEBUG: text bbox ($lab): [$x0, $y0, $x1, $y1]; curpos = {@curpos.raku}";
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
        note "DEBUG: first-line-height = {$!font.first-line-height} points" if self.debug;
        $!page = $!pdf.add-page;
        # set my current point
        $!cpx = $!x0;
        $!cpy = $!pheight - $!tm - $!font.first-line-height;
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
        # on each page the default will be to:
        #   use the same as the document font but at 0.8 its size
        #   define the baseline as 0.5 in above the media box bottom (y < 0)
        #   define the print position at the right margin, align right (rj)
        #   format: Page n of N
        my $name  = $!font.name;
        my $size  = $!font.size * 0.8;
        my $basefont = find-basefont :pdf($!pdf), :$name;
        my $font = select-docfont :$basefont, :$size;
        my $x = $!x0 + $!width;
        my $y = $!y0 - (0.5 * i2p);
        my $npages = self.pdf.page-count;
        note "DEBUG: printing page number on $npages pages" if self.debug;
        for 1 .. $npages -> $n {
            my $page = self.pdf.page: $n;
            $page.gfx.print: "Page $n of $npages", :position[$x, $y],
                :font($font.font), :font-size($font.size),
                :align<right>;
        }
    }
    method setlinewidth($width where {$_ >= 0}, :$color) {
        self.SetLineWidth: $width;
        self.setcolor($color) if $color.defined;
    }
    method setdash(@pattern, $phase, :$color) {
        # TODO test this
        # @pattern is an array of mark-space (on,off) lengths in PS points to describe the dash pattern
        # $phase is the offset distance to the start of the first dash pattern (used to
        #   adjust the total stroke line to have symmetrical results)
        self.SetDashPattern: @pattern, $phase;
        self.setcolor($color) if $color.defined;
    }
    method setlinejoin($level where {0 <= $_ <= 1}) {
    }
    method setgray($level where {0 <= $_ <= 1}) {
        self.SetStrokeGray: $level;
        self.SetFillGray:   $level;
    }
    method setcolor(
        $color # a list of 1 to 4 elements
        ) {
        my $ne = $color.elems;
        if $ne == 1 {
            # gray
            self.setgray: $color[0];
        }
        elsif $ne == 3 {
            # rgb
            self.setrgb: $color[*];
        }
        elsif $ne == 4 {
            # cmyk
            self.setcmyk: $color[*];
        }
        else {
            die "FATAL: color method has $ne elements but should have 1 (gray level), 3 (RGB) , or 4 (CYMK)";
        }
    }

    method setcmyk(*@a) {
        my $ne = @a.elems;
        if $ne != 4 {
            die "FATAL: cmyk method requires 4 values but received $ne";
        }
        my ($c,$m,$y,$k) = @a;
        self!set-cmyk: $c, $m, $y, $k;
    }

    method !set-cmyk(
        $c where {0 <= $_ <= 1},
        $m where {0 <= $_ <= 1},
        $y where {0 <= $_ <= 1},
        $k where {0 <= $_ <= 1},
        ) {
        use PDF::Content::Color :cmyk;
        self.gfx.FillColor:   cmyk($c, $m, $y, $k);
        self.gfx.StrokeColor: cmyk($c, $m, $y, $k);
    }

    method setrgb(*@a) {
        my $ne = @a.elems;
        if $ne != 3 {
            die "FATAL: rgb method requires 3 values but received $ne";
        }
        my ($r,$g,$b) = @a;
        self!set-rgb: $r, $g, $b;
    }
    method !set-rgb(
        $r where {0 <= $_ <= 1},
        $g where {0 <= $_ <= 1},
        $b where {0 <= $_ <= 1},
        ) {
        self.SetStrokeRGB: $r, $g, $b;
        self.SetFillRGB:   $r, $g, $b;
    }

    method save {
        self.Save;
    }
    method restore {
        self.Restore;
    }

    method !value2radians($val is copy --> Real) {
        note "DEBUG: v2r, input val = '$val'" if self.debug > 2;
        if $val ~~ /:i ^ (<[\d.+-]>+) (d|deg||rad|r)? $/ {
            $val = +$0;
            return $val if not $1.defined;
            my $units = ~$1;
            given $units {
                when /d|deg/   { $val *= deg2rad }
                when /r|rad/   { $val }
                default {
                    die "FATAL: Unknown units in input value '$val'";
                }
            }
        }
        note "DEBUG: v2r, output val = $val radians" if self.debug > 2;
        return $val;
    }

    method !value2points($val is copy, --> Real) {
        note "DEBUG: v2p, input val = '$val'" if self.debug > 2;
        my $oval = $val;
        if $val ~~ /:i ^ (<[\d.+-]>+) (in|cm|mm|ft)? $/ {
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
        note "DEBUG: v2p, output val = $val points" if self.debug > 2;
        return $val;
    }

    method ellipse(:$x!, :$y!, :$a!, :$b!,
        :$angle is copy,
        :$fill = False,
        :$color = [0], # black
        :$linewidth = 0
        ) {
        $angle = self!value2radians($angle) if $angle.defined;
        my $cx = self!value2points: $x;
        my $cy = self!value2points: $y;
        my $ca = self!value2points: $a;
        my $cb = self!value2points: $b;
        self!draw-ellipse($cx, $cy, $ca, $cb, :$fill, :$linewidth, :$color);
    }
    method !draw-ellipse($x, $y, $a, $b,
        Real :$angle, # radians
        :$fill = False,
        :$color = [0], # black
        :$linewidth = 0
        ) {
        self.Save;
        if $angle.defined {
            self.page.gfx.transform: :rotate($angle);
        }
        self.setlinewidth: $linewidth, :$color;

        note "DEBUG: draw-ellipse: x = $x, y = $y, a = $a, b = $b" if self.debug;
        # from stack overflow: copyright 2022 by Spencer Mortenson
        # treat $a as length in x direction, $b as length in y direction
        constant c = 0.551915024495;
        if 0 {
            # TODO use .transform: :scale[$a,$b]
            my $tx = $x;
            my $ty = $y;
            self.page.gfx.transform: :translate[$tx, $ty];
            self.page.gfx.transform: :scale[$a, $b];
            self.MoveTo: 1, 0;
            # use four curves (x/y)
            self.CurveTo:  c, 1,  1, c,  1, 0;
            self.CurveTo:  1,-c,  c,-1,  0,-1;
            self.CurveTo: -c,-1, -1,-c, -1, 0;
            self.CurveTo: -1, c, -c, 1,  0, 1;
            self.ClosePath;
            if $fill { self.Fill; }
            else { self.Stroke; }
        }
        else {
            # Draw the elipse starting at the top and working
            # clockwise.
            self.page.gfx.transform: :translate[$x, $y];
            self.MoveTo: 0*$a, 1*$b;
            # use four curves (x/y)
            self.CurveTo:  c*$a, 1*$b,  1*$a, c*$b,  1*$a, 0*$b;
            self.CurveTo:  1*$a,-c*$b,  c*$a,-1*$b,  0*$a,-1*$b;
            self.CurveTo: -c*$a,-1*$b, -1*$a,-c*$b, -1*$a, 0*$b;
            self.CurveTo: -1*$a, c*$b, -c*$a, 1*$b,  0*$a, 1*$b;
            self.ClosePath;
            if $fill { self.Fill; }
            else { self.Stroke; }
        }
        self.Restore;
    }

    # This is the method that the other rectangle methods should resolve to
    # as it actually renders the figure.
    method !draw-rectangle(Numeric $llx, Numeric $lly, Numeric $urx, Numeric $ury,
        :$angle, # radians
        :$fill = False,
        :$color = [0], # black
        :$linewidth = 0,
        ) {
        self.Save;
        if $angle.defined {
            self.page.gfx.transform: :rotate($angle);
        }
        self.setlinewidth: $linewidth, :$color;
        self.MoveTo: $llx, $lly;
        self.LineTo: $urx, $lly;
        self.LineTo: $urx, $ury;
        self.LineTo: $llx, $ury;
        self.ClosePath;
        if $fill { self.Fill; }
        else { self.Stroke; }
        self.Restore;
    }
    multi method rectangle($llx is copy, $lly is copy, $urx is copy, $ury is copy,
        :$angle is copy,
        :$fill = False,
        :$color = [0], # black
        :$linewidth = 0
        ) {
        $angle = self!value2radians($angle) if $angle.defined;
        # from upper-left corner
        $llx = self!value2points: $llx;
        $lly = self!value2points: $lly;
        $urx = self!value2points: $urx;
        $ury = self!value2points: $ury;
        self!draw-rectangle: $llx, $lly, $urx, $ury, :$fill, :$linewidth, :$angle, :$color;
    }

    multi method rectangle(:$llx! is copy, :$ury! is copy, :$width!, :$height!,
        :$angle is copy,
        :$fill = False,
        :$color = [0], # black
        :$linewidth = 0
        ) {
        $angle = self!value2radians($angle) if $angle.defined;
        # from upper-left corner
        $llx = self!value2points: $llx;
        $ury = self!value2points: $ury;
        my $w = self!value2points: $width;
        my $h = self!value2points: $height;
        my $urx = $llx + $w;
        my $lly = $ury - $h;
        self!draw-rectangle: $llx, $lly, $urx, $ury, :$fill, :$linewidth, :$angle, :$color;
    }
    multi method rectangle(:$urx! is copy, :$ury! is copy, :$width!, :$height!,
        :$angle is copy,
        :$fill = False,
        :$color = [0], # black
        :$linewidth = 0
        ) {
        $angle = self!value2radians($angle) if $angle.defined;
        # from upper-right corner
        $urx = self!value2points: $urx;
        $ury = self!value2points: $ury;
        my $w = self!value2points: $width;
        my $h = self!value2points: $height;
        my $llx = $urx - $w;
        my $lly = $ury - $h;
        self!draw-rectangle: $llx, $lly, $urx, $ury, :$fill, :$linewidth, :$angle, :$color;
    }
    multi method rectangle(:$urx! is copy, :$lly! is copy, :$width!, :$height!,
        :$angle is copy,
        :$fill = False,
        :$color = [0], # black
        :$linewidth = 0
        ) {
        $angle = self!value2radians($angle) if $angle.defined;
        # from lower-right corner
        $urx = self!value2points: $urx;
        $lly = self!value2points: $lly;
        my $w = self!value2points: $width;
        my $h = self!value2points: $height;
        my $llx = $urx - $w;
        my $ury = $lly + $h;
        self!draw-rectangle: $llx, $lly, $urx, $ury, :$fill, :$linewidth, :$angle, :$color;
    }
    multi method rectangle(:$cx! is copy, :$cy! is copy, :$width!, :$height!,
        :$angle is copy,
        :$fill = False,
        :$color = [0], # black
        :$linewidth = 0
        ) {
        $angle = self!value2radians($angle) if $angle.defined;
        # from the center
        $cx = self!value2points: $cx;
        $cy = self!value2points: $cy;
        my $hw = 0.5 * self!value2points: $width;
        my $hh = 0.5 * self!value2points: $height;

        my $llx = $cx - $hw;
        my $lly = $cy - $hw;
        my $urx = $cx + $hh;
        my $ury = $cy + $hh;
        self!draw-rectangle: $llx, $lly, $urx, $ury, :$fill, :$linewidth, :$angle, :$color;
    }

    method wedge(
        # TODO finish
        :$cx! is copy, :$cy! is copy, :$radius!,
        :$start-angle!, :$end-angle!,
        :$fill = False,
        :$color = [0], # black
        :$linewidth = 0
        ) {
    }

    method circular-arc(
        # TODO finish
        :$cx! is copy, :$cy! is copy, :$radius!,
        :$start-angle!, :$end-angle!,
        :$fill = False,
        :$color = [0], # black
        :$linewidth = 0
        ) {
        $cx    = self!value2points: $cx;
        $cy    = self!value2points: $cy;
        my $r  = self!value2points: $radius;
        my $sa = self!value2radians: $start-angle;
        my $ea = self!value2radians: $end-angle;
        # Scheme is to create the circle, then
        # create a triangle to cut out the
        # perimeter between the desired angles.
        self.Save;
        # translate to the center
        # rotate
        # create the circle
        # create the cutting wedge with radius 2r
        self.wedge: :cx(0), :cy(0), :radius(2*$r), :start-angle($sa), :end-angle($ea), :fill(True);
        self.Restore;
    }

    method elliptical-arc(
        # TODO finish
        :$cx! is copy, :$cy! is copy, :$radius!,
        :$a! is copy, :$b! is copy,
        :$start-angle!, :$end-angle!,
        :$rot-angle = 0,
        :$fill = False,
        :$color = [0], # black
        :$linewidth = 0
        ) {
        $cx = self!value2points: $cx;
        $cy = self!value2points: $cy;
        $a  = self!value2points: $b;
        $b  = self!value2points: $b;
        my $sa = self!value2radians: $start-angle;
        my $ea = self!value2radians: $end-angle;
        my $ra = self!value2radians: $rot-angle;
        # Scheme is to create the ellipse, then
        # create a triangle to cut out the
        # perimeter between the desired angles.
    }

    multi method rectangle(:$llx! is copy, :$lly! is copy, :$width!, :$height!,
        :$fill = False,
        :$color = [0], # black
        :$linewidth = 0
        ) {
        # from lower-left corner
        $llx = self!value2points: $llx;
        $lly = self!value2points: $lly;
        my $w = self!value2points: $width;
        my $h = self!value2points: $height;
        my $urx = $llx + $w;
        my $ury = $lly + $h;
        self!draw-rectangle: $llx, $lly, $urx, $ury, :$fill, :$linewidth, :$color;
    }

    multi method circle(:$x!, :$y!, :$radius!,
        :$fill = False,
        :$color = [0], # black
        :$linewidth = 0
        ) {
        my $cx = self!value2points: $x;
        my $cy = self!value2points: $y;
        my $cr = self!value2points: $radius;
        self!draw-circle($cx, $cy, $cr, :$fill, :$linewidth, :$color);
    }
    method !draw-circle($x, $y, $r,
        :$fill = False,
        :$color = [0], # black
        :$linewidth = 0
        ) {
        self.Save;
        self.setlinewidth: $linewidth, :$color;
        # from stack overflow: copyright 2022 by Spencer Mortenson
        self.page.gfx.transform: :translate[$x, $y];
        constant c = 0.551915024495;
        self.MoveTo: 0*$r, 1*$r; # top of the circle
        # use four curves
        self.CurveTo:  c*$r, 1*$r,  1*$r, c*$r,  1*$r, 0*$r;
        self.CurveTo:  1*$r,-c*$r,  c*$r,-1*$r,  0*$r,-1*$r;
        self.CurveTo: -c*$r,-1*$r, -1*$r,-c*$r, -1*$r, 0*$r;
        self.CurveTo: -1*$r, c*$r, -c*$r, 1*$r,  0*$r, 1*$r;
        self.ClosePath;
        if $fill { self.Fill; }
        else { self.Stroke; }
        self.Restore;
    }

    method polyline(@pts, :$fill = False, :$closepath = False,
        :$color = [0], # black
        :$linewidth = 0
        ) {
        # array of x/y points, path is not closed
        my $np = @pts.elems;
        die "FATAL: polyline points array is empty" if not $np;
        die "FATAL: polyline points array ($np pts) must have an even number of entries" if $np mod 2;
        my $x = @pts.shift;
        my $y = @pts.shift;
        self.Save;
        self.SetLineWidth: $linewidth;
        self.setcolor: $color;
        self.MoveTo: $x, $y;
        while @pts.elems {
            $x = @pts.shift;
            $y = @pts.shift;
            self.LineTo: $x, $y;
        }
        self.ClosePath if $closepath;
        if $closepath and $fill { self.Fill; }
        else { self.Stroke; }
        self.Restore;
    }
    method polygon(@pts, :$fill = False,
        :$color = [0], # black
        :$linewidth = 0
        ) {
        # array of x/y points, path is closed
        my $np = @pts.elems;
        die "FATAL: polygon points array is empty" if not @pts.elems;
        die "FATAL: polygon points array ($np pts) must have an even number of entries" if $np mod 2;
        self.polyline: @pts, :$fill, :closepath(True), :$linewidth, :$color;
    }

    method !moon-waxing(
        # waxing, New Moon to Full Moon, light increasing from the right (frac 0..1)
        Real $cx,
        Real $cy,
        Real $radius where {$_ >= 0},
        Real $frac where {0 <= $_ <= 1},
        :$angle,
        :$hemi where {/:i n|s/} = 'n',
        ) {

        self.Save;
        self.page.gfx.transform: :translate[$cx,$cy];

        if $hemi.defined and $hemi ~~ /:i s/ {
            self.page.gfx.transform: :reflect(pi/2);
        }
        if $angle.defined {
            self.page.gfx.transform: :rotate($angle);
        }

        if $frac < 0.5 {
            # New Moon to First Quarter
            # 1. left semicircle is black
            #    make black-filled circle
            self!draw-circle: 0, 0, $radius, :fill(True);
            #    make white square covering right semicircle
            self.rectangle: :cx($radius), :cy(0), :width(2*$radius), :height(2*$radius), :fill(True), :color(1);
            # 2. black on right semicircle
            #    when frac = 0.0, a = radius
            #    when frac = 0.5, a = 0
            #    make black-filled ellipse with a = radius - (2 * radius * frac)
            my $dfa = 2 * $radius * $frac;
            self!draw-ellipse: 0, 0, $radius - $dfa, $radius, :fill(True);
        }
        elsif $frac >= 0.5 {
            # First Quarter to Full Moon
            # 1. right semicircle is white
            #    make black circle
            self!draw-circle: 0, 0, $radius, :fill(True);
            #    make white-filled square covering right semicircle
            self.rectangle: :cx($radius), :cy(0), :width(2*$radius), :height(2*$radius), :fill(True), :color(1);
            # 2. white on left semicircle
            #    when frac = 1.0, a = radius
            #    when frac = 0.5, a = 0
            #    make white-filled ellipse with a = (2 * radius * frac) - radius
            my $dfa = 2 * $radius * $frac;
            self!draw-ellipse: 0, 0, $dfa - $radius, $radius, :fill(True), :color(1);
        }
        # 3. stroke the circle's circumference
        self!draw-circle: 0, 0, $radius;
        self.Restore;
    }

    method !moon-waning(
        # waning, Full Moon to New moon, darkness increasing from the
        # right (frac 1..0)
        Real $cx,
        Real $cy,
        Real $radius where {$_ >= 0},
        Real $frac where {0 <= $_ <= 1},
        :$angle,
        :$hemi where {/:i n|s/ } = 'n',
        ) {
        self.Save;
        self.page.gfx.transform: :translate[$cx,$cy];

        if $hemi.defined and $hemi ~~ /:i s/ {
            self.page.gfx.transform: :reflect(pi/2);
        }
        if $angle.defined {
            self.page.gfx.transform: :rotate($angle);
        }

        if $frac >= 0.5 {
            # Full Moon to Third Quarter
            # 1. right semicircle is white to begin with
            #    make black circle
            self!draw-circle: 0, 0, $radius, :fill(True);
            #    make white-filled square covering left semicircle
            self.rectangle: :cx(-$radius), :cy(0), :width(2*$radius), :height(2*$radius), :fill(True), :color(1);
            # 2. white on right semicircle is frac - 0.5
            #    make white-filled ellipse with a = (2 * radius * frac) - radius
            my $dfa = 2 * $radius * $frac;
            self!draw-ellipse: 0, 0, $dfa - $radius, $radius, :fill(True), :color(1);
        }
        elsif $frac < 0.5 {
            # Third Quarter to New Moon
            # 1. left semicircle is white to begin with
            #    make black-filled circle
            self!draw-circle: 0, 0, $radius, :fill(True);
            #    make white square covering left semicircle
            self.rectangle: :cx(-$radius), :cy(0), :width(2*$radius), :height(2*$radius),
                            :fill(True), :color(1);
            # 2. black on left semicircle is 0.5 - frac
            #    make black-filled ellipse with a = radius - (2 * radius * frac)
            my $dfa = 2 * $radius * $frac;
            self!draw-ellipse: 0, 0, $radius - $dfa, $radius, :fill(True);
        }
        # 3. stroke the circle's circumference
        self!draw-circle: 0, 0, $radius;
        self.Restore;
    }

    method moon-phase(
        :$cx! is copy,
        :$cy! is copy,
        :$radius! is copy,
        :$frac! where {0 <= $_ <= 1},
        :$type! where {/:i wax|wan/},
        :$hemi where {/:i n|s/} = 'n',
        :$angle is copy,
        ) {
        # Until we get circular and elliptical arcs we will have
        # to use circles and ellipses and overlay black with
        # white for certain input combinations.
        $cx     = self!value2points: $cx;
        $cy     = self!value2points: $cy;
        $radius = self!value2points: $radius;
        $angle  = self!value2radians($angle) if $angle.defined;

        if $type.contains('wax') {
            # Waxing: New Moon to Full Moon, light increasing from the right (frac 0..1)
            # (from the left in the Southern Hemisphere).
            self!moon-waxing: $cx, $cy, $radius, $frac, :$angle, :$hemi;
        }
        else {
            # Waning, Full Moon to New moon, darkness increasing from the right (frac 1..0)
            # (from the left in the Southern Hemisphere).
            self!moon-waning: $cx, $cy, $radius, $frac, :$angle, :$hemi;
        }
    }

    method get-gfx-state(:$delta) {
        if $delta.defined {
            return self.page.gfx.graphics-state(:$delta);
        }
        else {
            return self.page.gfx.graphics-state;
        }
    }

    method get-content() {
        return self.page.gfx.content-dump;
    }

    # Many other methods are provided by roles "PDF-role"
    # and "AFM-role".
    # Note those roles are auto-generated by program
    # dev/generate-code.raku.

    method show-media(:$names) {
        # see all the available media keys
        my %e = PageSizes.enums;

        if $names {
            # just return the names
            return %e.keys.sort
        }

        # fancier, more info
        say "Media names and sizes (in PS points)";
        say "  Orientation: portrait";
        say "  Size => [width height]";
        say();
        say "                   Points       Inches";
        my $nc = 0;
        my ($n2, $n3) = 0, 0;
        my ($n2i, $n3i) = 0, 0;
        for %e.keys -> $k {
            my $v = %e{$k};
            my $n = $k.chars;
            $nc = $n if $nc < $n;

            # also get size of width and height
            my @n = $v.words;
            my $nw = @n[2].chars;
            my $nl = @n[3].chars;
            $n2 = $nw if $n2 < $nw;
            $n3 = $nl if $n3 < $nl;

            # and in inches
            my $wi = @n[2] / 72.0;
            my $li = @n[3] / 72.0;
            my $wis = sprintf '%5.2f', $wi;
            my $lis = sprintf '%5.2f', $li;
            my $nwi = $wis.chars;
            my $nli = $lis.chars;
            $n2i = $nwi if $n2i < $nwi;
            $n3i = $nli if $n3i < $nli;
        }
        for %e.keys.sort -> $k {
            my $v = %e{$k};
            my $nam = sprintf '%-*.*s', $nc, $nc, $k;

            my @n = $v.words;
            my $w = @n[2];
            my $l = @n[3];
            my $val = sprintf '%*.*s %*.*s',
                          $n2, $n2, $w,
                          $n3, $n3, $l;

            my $wi = @n[2] / 72.0;
            my $li = @n[3] / 72.0;
            my $wis = sprintf '%5.2f', $wi;
            my $lis = sprintf '%5.2f', $li;
            my $val2 = sprintf '%*.*s %*.*s',
                          $n2i, $n2i, $wis,
                          $n3i, $n3i, $lis;

            say "    $nam => [$val] [$val2]";
        }
    }
} # end of class Doc


sub make-page(Doc :$doc!,
              :$media     = <Letter>, # default
              :$landscape = False,
              :$debug,
             ) is export {
    my $page = $doc.pdf.page;
    # always save the CTM
    $doc.save;

    #set-media-box :$page, :$media;
    note $page.media-box if $debug;

    my $orient = "Portrait";
    my ($llx, $lly, $urx, $ury) = $page.media-box;
    note "media-box before translation: $llx, $lly, $urx, $ury" if $debug;
    my $pw = $urx - $llx;
    if $landscape {
        # just rotate the page
        ($llx, $lly, $urx, $ury) = to-landscape $page.media-box;
        $orient = "Landscape";
        $doc.translate: $pw, 0;
        $doc.rotate(90 * deg2rad);
        note "media-box after translation: $llx, $lly, $urx, $ury" if $debug;
    }
    $pw = $urx - $llx;

    my $cx = 0.5 * ($urx-$llx);
    my $cy = 0.5 * ($ury-$lly);

    # outline the page
    # method !rectangle(Real $llx, Real $lly, Real $urx, Real $ury,

    $doc.rectangle: 72, 72, $urx-72, $ury-72;
    # text at the center
    $doc.print: $orient, :x($cx), :y($cy), :align<center>, :valign<center>;

    # always restore the CTM
    $doc.restore;
}
