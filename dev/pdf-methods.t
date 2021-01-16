use Test;
use File::Temp;

use PDF::Document;

# plan N; # enter correct N after all desired tests pass

# global vars
my ($of, $fh) = tempfile;
my ($doc, $x, $y);

lives-ok {
    TextLeading
}, "testing method ''";

lives-ok {
    Tl
}, "testing method '', alias 'Tl'";

lives-ok {
    my $level = 0.5;
    SetStrokeGray($level)
}, "testing method 'SetStrokeGray'";

lives-ok {
    my $level = 0.5;
    G($level)
}, "testing method 'SetStrokeGray', alias 'G'";

lives-ok {
    my $level = 0.5;
    SetFillGray($level)
}, "testing method 'SetFillGray'";

lives-ok {
    my $level = 0.5;
    g($level)
}, "testing method 'SetFillGray', alias 'g'";

lives-ok {
    my $r = 0.5;
    my $g = 0.5;
    my $b = 0.5;
    SetStrokeRGB($r, $g, $b)
}, "testing method 'SetStrokeRGB'";

lives-ok {
    my $r = 0.5;
    my $g = 0.5;
    my $b = 0.5;
    RG($r, $g, $b)
}, "testing method 'SetStrokeRGB', alias 'RG'";

lives-ok {
    my $r = 0.5;
    my $g = 0.5;
    my $b = 0.5;
    SetFillRGB($r, $g, $b)
}, "testing method 'SetFillRGB'";

lives-ok {
    my $r = 0.5;
    my $g = 0.5;
    my $b = 0.5;
    rg($r, $g, $b)
}, "testing method 'SetFillRGB', alias 'rg'";

lives-ok {
    Save()
}, "testing method 'Save'";

lives-ok {
    q()
}, "testing method 'Save', alias 'q'";

lives-ok {
    Restore()
}, "testing method 'Restore'";

lives-ok {
    Q()
}, "testing method 'Restore', alias 'Q'";

lives-ok {
    my $width = 5;
    SetLineWidth($width)
}, "testing method 'SetLineWidth'";

lives-ok {
    my $width = 5;
    w($width)
}, "testing method 'SetLineWidth', alias 'w'";

lives-ok {
    my $cap-style = 1;
    SetLineCap($cap-style)
}, "testing method 'SetLineCap'";

lives-ok {
    my $cap-style = 1;
    J($cap-style)
}, "testing method 'SetLineCap', alias 'J'";

lives-ok {
    my $join-style = 1;
    SetLineJoin($join-style)
}, "testing method 'SetLineJoin'";

lives-ok {
    my $join-style = 1;
    j($join-style)
}, "testing method 'SetLineJoin', alias 'j'";

lives-ok {
    my $ratio = 0.5;
    SetMiterLimit($ratio)
}, "testing method 'SetMiterLimit'";

lives-ok {
    my $ratio = 0.5;
    M($ratio)
}, "testing method 'SetMiterLimit', alias 'M'";

lives-ok {
    my $dashArray = 0.5;
    my $dashPhase = 0.5;
    SetDashPattern($dashArray, $dashPhase)
}, "testing method 'SetDashPattern'";

lives-ok {
    my $dashArray = 0.5;
    my $dashPhase = 0.5;
    d($dashArray, $dashPhase)
}, "testing method 'SetDashPattern', alias 'd'";

lives-ok {
    my $intent = 100;
    SetRenderingIntent($intent)
}, "testing method 'SetRenderingIntent'";

lives-ok {
    my $intent = 100;
    ri($intent)
}, "testing method 'SetRenderingIntent', alias 'ri'";

lives-ok {
    BeginText()
}, "testing method 'BeginText'";

lives-ok {
    BT()
}, "testing method 'BeginText', alias 'BT'";

lives-ok {
    EndText()
}, "testing method 'EndText'";

lives-ok {
    ET()
}, "testing method 'EndText', alias 'ET'";

lives-ok {
    my $tx = 100;
    my $ty = 100;
    TextMove($tx, $ty)
}, "testing method 'TextMove'";

lives-ok {
    my $tx = 100;
    my $ty = 100;
    Td($tx, $ty)
}, "testing method 'TextMove', alias 'Td'";

lives-ok {
    my $tx = 100;
    my $ty = 100;
    TextMoveSet($tx, $ty)
}, "testing method 'TextMoveSet'";

lives-ok {
    my $tx = 100;
    my $ty = 100;
    TD($tx, $ty)
}, "testing method 'TextMoveSet', alias 'TD'";

lives-ok {
    TextNextLine
}, "testing method ''";

lives-ok {
    T*
}, "testing method '', alias 'T*'";

lives-ok {
    my $string = "some text";
    ShowText($string)
}, "testing method 'ShowText'";

lives-ok {
    my $string = "some text";
    Tj($string)
}, "testing method 'ShowText', alias 'Tj'";

lives-ok {
    my $string = "some text";
    MoveShowText($string)
}, "testing method 'MoveShowText'";

lives-ok {
    my $aw = 100;
    my $ac = 100;
    my $string = "some text";
    MoveSetShowText($aw, $ac, $string)
}, "testing method 'MoveSetShowText'";

lives-ok {
    my $x = 100;
    my $y = 100;
    MoveTo($x, $y)
}, "testing method 'MoveTo'";

lives-ok {
    my $x = 100;
    my $y = 100;
    m($x, $y)
}, "testing method 'MoveTo', alias 'm'";

lives-ok {
    my $x = 100;
    my $y = 100;
    LineTo($x, $y)
}, "testing method 'LineTo'";

lives-ok {
    my $x = 100;
    my $y = 100;
    l($x, $y)
}, "testing method 'LineTo', alias 'l'";

lives-ok {
    my $x1 = 100;
    my $y1 = 100;
    my $x2 = 100;
    my $y2 = 100;
    my $x3 = 100;
    my $y3 = 100;
    CurveTo($x1, $y1, $x2, $y2, $x3, $y3)
}, "testing method 'CurveTo'";

lives-ok {
    my $x1 = 100;
    my $y1 = 100;
    my $x2 = 100;
    my $y2 = 100;
    my $x3 = 100;
    my $y3 = 100;
    c($x1, $y1, $x2, $y2, $x3, $y3)
}, "testing method 'CurveTo', alias 'c'";

lives-ok {
    ClosePath
}, "testing method ''";

lives-ok {
    h
}, "testing method '', alias 'h'";

lives-ok {
    my $x = 100;
    my $y = 100;
    my $width = 5;
    my $Height = 100;
    Rectangle($x, $y, $width, $Height)
}, "testing method 'Rectangle'";

lives-ok {
    my $x = 100;
    my $y = 100;
    my $width = 5;
    my $Height = 100;
    re($x, $y, $width, $Height)
}, "testing method 'Rectangle', alias 're'";

lives-ok {
    Stroke()
}, "testing method 'Stroke'";

lives-ok {
    S()
}, "testing method 'Stroke', alias 'S'";

lives-ok {
    CloseStroke()
}, "testing method 'CloseStroke'";

lives-ok {
    s()
}, "testing method 'CloseStroke', alias 's'";

lives-ok {
    Fill()
}, "testing method 'Fill'";

lives-ok {
    f()
}, "testing method 'Fill', alias 'f'";

lives-ok {
    FillStroke()
}, "testing method 'FillStroke'";

lives-ok {
    B()
}, "testing method 'FillStroke', alias 'B'";

lives-ok {
    CloseFillStroke()
}, "testing method 'CloseFillStroke'";

lives-ok {
    b()
}, "testing method 'CloseFillStroke', alias 'b'";

lives-ok {
    Clip()
}, "testing method 'Clip'";

lives-ok {
    W()
}, "testing method 'Clip', alias 'W'";

