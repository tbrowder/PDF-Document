#================================================================
#
# THIS FILE IS AUTO-GENERATED - EDITS MAY BE LOST WITHOUT WARNING
#
#================================================================
use Test;
use File::Temp;
use PDF::Document;
plan 39;
# global vars
my ($of, $fh) = tempfile;
my ($doc, $x, $y);
$doc = Doc.new;

# test 1
lives-ok {
    $doc.TextLeading;
}, "testing method 'TextLeading'";
# test 2
lives-ok {
    $doc.Tl;
}, "testing method 'TextLeading', alias 'Tl'";
# test 3
lives-ok {
    $doc.q;
    my $level = 0.5;
    $doc.SetStrokeGray($level);
    $doc.Q;
}, "testing method 'SetStrokeGray'";
# test 4
lives-ok {
    $doc.q;
    my $level = 0.5;
    $doc.G($level);
    $doc.Q;
}, "testing method 'SetStrokeGray', alias 'G'";
# test 5
lives-ok {
    $doc.q;
    my $level = 0.5;
    $doc.SetFillGray($level);
    $doc.Q;
}, "testing method 'SetFillGray'";
# test 6
lives-ok {
    $doc.q;
    my $level = 0.5;
    $doc.g($level);
    $doc.Q;
}, "testing method 'SetFillGray', alias 'g'";
# test 7
lives-ok {
    $doc.q;
    my $r = 0.5;
    my $g = 0.5;
    my $b = 0.5;
    $doc.SetStrokeRGB($r, $g, $b);
    $doc.Q;
}, "testing method 'SetStrokeRGB'";
# test 8
lives-ok {
    $doc.q;
    my $r = 0.5;
    my $g = 0.5;
    my $b = 0.5;
    $doc.RG($r, $g, $b);
    $doc.Q;
}, "testing method 'SetStrokeRGB', alias 'RG'";
# test 9
lives-ok {
    $doc.q;
    my $r = 0.5;
    my $g = 0.5;
    my $b = 0.5;
    $doc.SetFillRGB($r, $g, $b);
    $doc.Q;
}, "testing method 'SetFillRGB'";
# test 10
lives-ok {
    $doc.q;
    my $r = 0.5;
    my $g = 0.5;
    my $b = 0.5;
    $doc.rg($r, $g, $b);
    $doc.Q;
}, "testing method 'SetFillRGB', alias 'rg'";
# test 11
lives-ok {
    $doc.q;
    my $width = 5;
    $doc.SetLineWidth($width);
    $doc.Q;
}, "testing method 'SetLineWidth'";
# test 12
lives-ok {
    $doc.q;
    my $width = 5;
    $doc.w($width);
    $doc.Q;
}, "testing method 'SetLineWidth', alias 'w'";
# test 13
lives-ok {
    $doc.q;
    my $cap-style = 1;
    $doc.SetLineCap($cap-style);
    $doc.Q;
}, "testing method 'SetLineCap'";
# test 14
lives-ok {
    $doc.q;
    my $cap-style = 1;
    $doc.J($cap-style);
    $doc.Q;
}, "testing method 'SetLineCap', alias 'J'";
# test 15
lives-ok {
    $doc.q;
    my $join-style = 1;
    $doc.SetLineJoin($join-style);
    $doc.Q;
}, "testing method 'SetLineJoin'";
# test 16
lives-ok {
    $doc.q;
    my $join-style = 1;
    $doc.j($join-style);
    $doc.Q;
}, "testing method 'SetLineJoin', alias 'j'";
# test 17
lives-ok {
    $doc.q;
    my $ratio = 0.5;
    $doc.SetMiterLimit($ratio);
    $doc.Q;
}, "testing method 'SetMiterLimit'";
# test 18
lives-ok {
    $doc.q;
    my $ratio = 0.5;
    $doc.M($ratio);
    $doc.Q;
}, "testing method 'SetMiterLimit', alias 'M'";
# test 19
lives-ok {
    $doc.q;
    my $dashArray = [4, 2];
    my $dashPhase = 0;
    $doc.SetDashPattern($dashArray, $dashPhase);
    $doc.Q;
}, "testing method 'SetDashPattern'";
# test 20
lives-ok {
    $doc.q;
    my $dashArray = [4, 2];
    my $dashPhase = 0;
    $doc.d($dashArray, $dashPhase);
    $doc.Q;
}, "testing method 'SetDashPattern', alias 'd'";
# test 21
lives-ok {
    $doc.BT;
    my $tx = 100;
    my $ty = 100;
    $doc.TextMove($tx, $ty);
    $doc.ET;
}, "testing method 'TextMove'";
# test 22
lives-ok {
    $doc.BT;
    my $tx = 100;
    my $ty = 100;
    $doc.Td($tx, $ty);
    $doc.ET;
}, "testing method 'TextMove', alias 'Td'";
# test 23
lives-ok {
    $doc.BT;
    my $tx = 100;
    my $ty = 100;
    $doc.TextMoveSet($tx, $ty);
    $doc.ET;
}, "testing method 'TextMoveSet'";
# test 24
lives-ok {
    $doc.BT;
    my $tx = 100;
    my $ty = 100;
    $doc.TD($tx, $ty);
    $doc.ET;
}, "testing method 'TextMoveSet', alias 'TD'";
# test 25
lives-ok {
    $doc.BT;
    $doc.TextNextLine;
    $doc.ET;
}, "testing method 'TextNextLine'";
# test 26
lives-ok {
    $doc.BT;
    my $string = "some text";
    $doc.ShowText($string);
    $doc.ET;
}, "testing method 'ShowText'";
# test 27
lives-ok {
    $doc.BT;
    my $string = "some text";
    $doc.Tj($string);
    $doc.ET;
}, "testing method 'ShowText', alias 'Tj'";
# test 28
lives-ok {
    $doc.BT;
    my $string = "some text";
    $doc.MoveShowText($string);
    $doc.ET;
}, "testing method 'MoveShowText'";
# test 29
lives-ok {
    $doc.BT;
    my $aw = 100;
    my $ac = 100;
    my $string = "some text";
    $doc.MoveSetShowText($aw, $ac, $string);
    $doc.ET;
}, "testing method 'MoveSetShowText'";
# test 30
lives-ok {
    my $x = 100;
    my $y = 100;
    $doc.MoveTo($x, $y);
}, "testing method 'MoveTo'";
# test 31
lives-ok {
    my $x = 100;
    my $y = 100;
    $doc.m($x, $y);
}, "testing method 'MoveTo', alias 'm'";
# test 32
lives-ok {
    my $x = 100;
    my $y = 100;
    $doc.LineTo($x, $y);
}, "testing method 'LineTo'";
# test 33
lives-ok {
    my $x = 100;
    my $y = 100;
    $doc.l($x, $y);
}, "testing method 'LineTo', alias 'l'";
# test 34
lives-ok {
    my $x1 = 100;
    my $y1 = 100;
    my $x2 = 100;
    my $y2 = 100;
    my $x3 = 100;
    my $y3 = 100;
    $doc.CurveTo($x1, $y1, $x2, $y2, $x3, $y3);
}, "testing method 'CurveTo'";
# test 35
lives-ok {
    my $x1 = 100;
    my $y1 = 100;
    my $x2 = 100;
    my $y2 = 100;
    my $x3 = 100;
    my $y3 = 100;
    $doc.c($x1, $y1, $x2, $y2, $x3, $y3);
}, "testing method 'CurveTo', alias 'c'";
# test 36
lives-ok {
    $doc.ClosePath;
}, "testing method 'ClosePath'";
# test 37
lives-ok {
    $doc.h;
}, "testing method 'ClosePath', alias 'h'";
# test 38
lives-ok {
    my $x = 100;
    my $y = 100;
    my $width = 5;
    my $Height = 100;
    $doc.Rectangle($x, $y, $width, $Height);
}, "testing method 'Rectangle'";
# test 39
lives-ok {
    my $x = 100;
    my $y = 100;
    my $width = 5;
    my $Height = 100;
    $doc.re($x, $y, $width, $Height);
}, "testing method 'Rectangle', alias 're'";
