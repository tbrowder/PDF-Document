use PDF::Lite;
use PDF::Content::Color :ColorName, :&color;

constant Margin = 100;
constant Top = 600;
constant Bottom = 100;
constant Width = 70;

sub deg2rad($d) { $d * pi / 180 }

sub draw-margin-line($_) {
    .Save;
    .StrokeColor = color Red;
    .MoveTo(Margin, Top);
    .LineTo(Margin, Bottom);
    .CloseFillStroke;
    .Restore;
}

sub right-to-left-arrow($_, $label) {
    constant ArrowHead = 3;
    .MoveTo(0,0);
    .LineTo(Width, 0);
    .Stroke;
    .MoveTo(Width, 0);
    .LineTo(Width - ArrowHead, ArrowHead);
    .LineTo(Width - ArrowHead, - ArrowHead);
    .CloseFillStroke;

    .print($label, :position[Width/2, 1])
        if $label;
}

my PDF::Lite $pdf .= new;
$pdf.add-page.gfx.graphics: -> $gfx {
    $gfx.font = $gfx.core-font('Helvetica'), 12;

    $gfx.&draw-margin-line;
    $gfx.transform: :translate[Margin, Top];

    for 0, 30 ... 180 {
        $gfx.Save;
        $gfx.&right-to-left-arrow(.Str);
        # reflect and re-draw in green
        $gfx.StrokeColor = color Green;
        $gfx.FillColor = color Green;
        my $reflect = deg2rad($_);
        $gfx.transform: :$reflect;
        $gfx.&right-to-left-arrow(.Str);
        $gfx.Restore;
        # move down
        $gfx.transform: :translate[0, -Width - 10];
    }
}

$pdf.save-as: "/tmp/reflect.pdf";
