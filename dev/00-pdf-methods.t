
#================================================================
#
# THIS FILE IS AUTO-GENERATED - EDITS MAY BE LOST WITHOUT WARNING
#
#================================================================

use Test;
use File::Temp;

use PDF::Document;

plan 61;

# global vars
my ($of, $fh) = tempfile;
my ($doc, $x, $y);
$doc = Doc.new;

# test 1
lives-ok {
    $doc.TextLeading
}, "testing method 'TextLeading'";

# test 2
lives-ok {
    $doc.Tl
}, "testing method 'TextLeading', alias 'Tl'";

# test 3
lives-ok {
    my $level = 0.5;
    $doc.SetStrokeGray($level)
}, "testing method 'SetStrokeGray'";

# test 4
lives-ok {
    my $level = 0.5;
    $doc.G($level)
}, "testing method 'SetStrokeGray', alias 'G'";

# test 5
lives-ok {
    my $level = 0.5;
    $doc.SetFillGray($level)
}, "testing method 'SetFillGray'";

# test 6
lives-ok {
    my $level = 0.5;
    $doc.g($level)
}, "testing method 'SetFillGray', alias 'g'";

# test 7
lives-ok {
    my $r = 0.5;
    my $g = 0.5;
    my $b = 0.5;
    $doc.SetStrokeRGB($r, $g, $b)
}, "testing method 'SetStrokeRGB'";

# test 8
lives-ok {
    my $r = 0.5;
    my $g = 0.5;
    my $b = 0.5;
    $doc.RG($r, $g, $b)
}, "testing method 'SetStrokeRGB', alias 'RG'";

# test 9
lives-ok {
    my $r = 0.5;
    my $g = 0.5;
    my $b = 0.5;
    $doc.SetFillRGB($r, $g, $b)
}, "testing method 'SetFillRGB'";

# test 10
lives-ok {
    my $r = 0.5;
    my $g = 0.5;
    my $b = 0.5;
    $doc.rg($r, $g, $b)
}, "testing method 'SetFillRGB', alias 'rg'";

# test 11
lives-ok {
    $doc.Save()
}, "testing method 'Save'";

# test 12
lives-ok {
    $doc.q()
}, "testing method 'Save', alias 'q'";

# test 13
lives-ok {
    $doc.Restore()
}, "testing method 'Restore'";

# test 14
lives-ok {
    $doc.Q()
}, "testing method 'Restore', alias 'Q'";

# test 15
lives-ok {
    my $width = 5;
    $doc.SetLineWidth($width)
}, "testing method 'SetLineWidth'";

# test 16
lives-ok {
    my $width = 5;
    $doc.w($width)
}, "testing method 'SetLineWidth', alias 'w'";

# test 17
lives-ok {
    my $cap-style = 1;
    $doc.SetLineCap($cap-style)
}, "testing method 'SetLineCap'";

# test 18
lives-ok {
    my $cap-style = 1;
    $doc.J($cap-style)
}, "testing method 'SetLineCap', alias 'J'";

# test 19
lives-ok {
    my $join-style = 1;
    $doc.SetLineJoin($join-style)
}, "testing method 'SetLineJoin'";

# test 20
lives-ok {
    my $join-style = 1;
    $doc.j($join-style)
}, "testing method 'SetLineJoin', alias 'j'";

# test 21
lives-ok {
    my $ratio = 0.5;
    $doc.SetMiterLimit($ratio)
}, "testing method 'SetMiterLimit'";

# test 22
lives-ok {
    my $ratio = 0.5;
    $doc.M($ratio)
}, "testing method 'SetMiterLimit', alias 'M'";

# test 23
lives-ok {
    my $dashArray = 0.5;
    my $dashPhase = 0.5;
    $doc.SetDashPattern($dashArray, $dashPhase)
}, "testing method 'SetDashPattern'";

# test 24
lives-ok {
    my $dashArray = 0.5;
    my $dashPhase = 0.5;
    $doc.d($dashArray, $dashPhase)
}, "testing method 'SetDashPattern', alias 'd'";

# test 25
lives-ok {
    my $intent = 100;
    $doc.SetRenderingIntent($intent)
}, "testing method 'SetRenderingIntent'";

# test 26
lives-ok {
    my $intent = 100;
    $doc.ri($intent)
}, "testing method 'SetRenderingIntent', alias 'ri'";

# test 27
lives-ok {
    $doc.BeginText()
}, "testing method 'BeginText'";

# test 28
lives-ok {
    $doc.BT()
}, "testing method 'BeginText', alias 'BT'";

# test 29
lives-ok {
    $doc.EndText()
}, "testing method 'EndText'";

# test 30
lives-ok {
    $doc.ET()
}, "testing method 'EndText', alias 'ET'";

# test 31
lives-ok {
    my $tx = 100;
    my $ty = 100;
    $doc.TextMove($tx, $ty)
}, "testing method 'TextMove'";

# test 32
lives-ok {
    my $tx = 100;
    my $ty = 100;
    $doc.Td($tx, $ty)
}, "testing method 'TextMove', alias 'Td'";

# test 33
lives-ok {
    my $tx = 100;
    my $ty = 100;
    $doc.TextMoveSet($tx, $ty)
}, "testing method 'TextMoveSet'";

# test 34
lives-ok {
    my $tx = 100;
    my $ty = 100;
    $doc.TD($tx, $ty)
}, "testing method 'TextMoveSet', alias 'TD'";

# test 35
lives-ok {
    $doc.TextNextLine
}, "testing method 'TextNextLine'";

# test 36
lives-ok {
    my $string = "some text";
    $doc.ShowText($string)
}, "testing method 'ShowText'";

# test 37
lives-ok {
    my $string = "some text";
    $doc.Tj($string)
}, "testing method 'ShowText', alias 'Tj'";

# test 38
lives-ok {
    my $string = "some text";
    $doc.MoveShowText($string)
}, "testing method 'MoveShowText'";

# test 39
lives-ok {
    my $aw = 100;
    my $ac = 100;
    my $string = "some text";
    $doc.MoveSetShowText($aw, $ac, $string)
}, "testing method 'MoveSetShowText'";

# test 40
lives-ok {
    my $x = 100;
    my $y = 100;
    $doc.MoveTo($x, $y)
}, "testing method 'MoveTo'";

# test 41
lives-ok {
    my $x = 100;
    my $y = 100;
    $doc.m($x, $y)
}, "testing method 'MoveTo', alias 'm'";

# test 42
lives-ok {
    my $x = 100;
    my $y = 100;
    $doc.LineTo($x, $y)
}, "testing method 'LineTo'";

# test 43
lives-ok {
    my $x = 100;
    my $y = 100;
    $doc.l($x, $y)
}, "testing method 'LineTo', alias 'l'";

# test 44
lives-ok {
    my $x1 = 100;
    my $y1 = 100;
    my $x2 = 100;
    my $y2 = 100;
    my $x3 = 100;
    my $y3 = 100;
    $doc.CurveTo($x1, $y1, $x2, $y2, $x3, $y3)
}, "testing method 'CurveTo'";

# test 45
lives-ok {
    my $x1 = 100;
    my $y1 = 100;
    my $x2 = 100;
    my $y2 = 100;
    my $x3 = 100;
    my $y3 = 100;
    $doc.c($x1, $y1, $x2, $y2, $x3, $y3)
}, "testing method 'CurveTo', alias 'c'";

# test 46
lives-ok {
    $doc.ClosePath
}, "testing method 'ClosePath'";

# test 47
lives-ok {
    $doc.h
}, "testing method 'ClosePath', alias 'h'";

# test 48
lives-ok {
    my $x = 100;
    my $y = 100;
    my $width = 5;
    my $Height = 100;
    $doc.Rectangle($x, $y, $width, $Height)
}, "testing method 'Rectangle'";

# test 49
lives-ok {
    my $x = 100;
    my $y = 100;
    my $width = 5;
    my $Height = 100;
    $doc.re($x, $y, $width, $Height)
}, "testing method 'Rectangle', alias 're'";

# test 50
lives-ok {
    $doc.Stroke()
}, "testing method 'Stroke'";

# test 51
lives-ok {
    $doc.S()
}, "testing method 'Stroke', alias 'S'";

# test 52
lives-ok {
    $doc.CloseStroke()
}, "testing method 'CloseStroke'";

# test 53
lives-ok {
    $doc.s()
}, "testing method 'CloseStroke', alias 's'";

# test 54
lives-ok {
    $doc.Fill()
}, "testing method 'Fill'";

# test 55
lives-ok {
    $doc.f()
}, "testing method 'Fill', alias 'f'";

# test 56
lives-ok {
    $doc.FillStroke()
}, "testing method 'FillStroke'";

# test 57
lives-ok {
    $doc.B()
}, "testing method 'FillStroke', alias 'B'";

# test 58
lives-ok {
    $doc.CloseFillStroke()
}, "testing method 'CloseFillStroke'";

# test 59
lives-ok {
    $doc.b()
}, "testing method 'CloseFillStroke', alias 'b'";

# test 60
lives-ok {
    $doc.Clip()
}, "testing method 'Clip'";

# test 61
lives-ok {
    $doc.W()
}, "testing method 'Clip', alias 'W'";

