unit role PDF::Document::Role;

use PDF::Lite;

has $.pdf;
has $.page;

#| Text line height
method TextLeading {
    $!page.gfx.TextLeading;
}
method Tl {
    $!page.gfx.TextLeading;
}

#| Set the stroking colour space to DeviceGray and set the gray level to use
#| for stroking operations, between 0.0 (black) and 1.0 (white).
method SetStrokeGray($level) {
    $!page.gfx.SetStrokeGray($level);
}
method G($level) {
    $!page.gfx.SetStrokeGray($level);
}

#| Same as G but used for non-stroking operations.
method SetFillGray($level) {
    $!page.gfx.SetFillGray($level);
}
method g($level) {
    $!page.gfx.SetFillGray($level);
}

#| Set the stroking colour space to DeviceRGB and set the colour to use for
#| stroking operations. Each operand is a number between 0.0 (minimum
#| intensity) and 1.0 (maximum intensity).
method SetStrokeRGB($r, $g, $b) {
    $!page.gfx.SetStrokeRGB($r, $g, $b);
}
method RG($r, $g, $b) {
    $!page.gfx.SetStrokeRGB($r, $g, $b);
}

#| Same as RG but used for non-stroking operations.
method SetFillRGB($r, $g, $b) {
    $!page.gfx.SetFillRGB($r, $g, $b);
}
method rg($r, $g, $b) {
    $!page.gfx.SetFillRGB($r, $g, $b);
}

#| Save the current graphics state on the graphics state stack
method Save() {
    $!page.gfx.Save();
}
method q() {
    $!page.gfx.Save();
}

#| Restore the graphics state by removing the most recently saved state from
#| the stack and making it the current state.
method Restore() {
    $!page.gfx.Restore();
}
method Q() {
    $!page.gfx.Restore();
}

#| Set the line width in the graphics state
method SetLineWidth($width) {
    $!page.gfx.SetLineWidth($width);
}
method w($width) {
    $!page.gfx.SetLineWidth($width);
}

#| Set the line cap style in the graphics state (see LineCap enum)
method SetLineCap($cap-style) {
    $!page.gfx.SetLineCap($cap-style);
}
method J($cap-style) {
    $!page.gfx.SetLineCap($cap-style);
}

#| Set the line join style in the graphics state (see LineJoin enum)
method SetLineJoin($join-style) {
    $!page.gfx.SetLineJoin($join-style);
}
method j($join-style) {
    $!page.gfx.SetLineJoin($join-style);
}

#| Set the miter limit in the graphics state
method SetMiterLimit($ratio) {
    $!page.gfx.SetMiterLimit($ratio);
}
method M($ratio) {
    $!page.gfx.SetMiterLimit($ratio);
}

#| Set the line dash pattern in the graphics state
method SetDashPattern($dashArray, $dashPhase) {
    $!page.gfx.SetDashPattern($dashArray, $dashPhase);
}
method d($dashArray, $dashPhase) {
    $!page.gfx.SetDashPattern($dashArray, $dashPhase);
}

#| Begin a text object, initializing $.TextMatrix, to the identity matrix.
#| Text objects cannot be nested.
method BeginText() {
    $!page.gfx.BeginText();
}
method BT() {
    $!page.gfx.BeginText();
}

#| End a text object, discarding the text matrix.
method EndText() {
    $!page.gfx.EndText();
}
method ET() {
    $!page.gfx.EndText();
}

#| Move to the start of the next line, offset from the start of the current
#| line by (tx, ty); where tx and ty are expressed in unscaled text space
#| units.
method TextMove($tx, $ty) {
    $!page.gfx.TextMove($tx, $ty);
}
method Td($tx, $ty) {
    $!page.gfx.TextMove($tx, $ty);
}

#| Move to the start of the next line, offset from the start of the current
#| line by (tx, ty). Set $.TextLeading to ty.
method TextMoveSet($tx, $ty) {
    $!page.gfx.TextMoveSet($tx, $ty);
}
method TD($tx, $ty) {
    $!page.gfx.TextMoveSet($tx, $ty);
}

#| Move to the start of the next line
method TextNextLine {
    $!page.gfx.TextNextLine;
}
    # alias method 'T*' cannot be used due to its invalid identifier in Raku
#| Show a text string
method ShowText($string) {
    $!page.gfx.ShowText($string);
}
method Tj($string) {
    $!page.gfx.ShowText($string);
}

#| Move to the next line and show a text string.
method MoveShowText($string) {
    $!page.gfx.MoveShowText($string);
}
    # alias method ''' cannot be used due to its invalid identifier in Raku
#| Move to the next line and show a text string, after setting $.WordSpacing
#| to aw and $.CharSpacing to ac
method MoveSetShowText($aw, $ac, $string) {
    $!page.gfx.MoveSetShowText($aw, $ac, $string);
}
    # alias method '"' cannot be used due to its invalid identifier in Raku
#| Begin a new sub-path by moving the current point to coordinates (x, y),
#| omitting any connecting line segment. If the previous path construction
#| operator in the current path was also m, the new m overrides it.
method MoveTo($x, $y) {
    $!page.gfx.MoveTo($x, $y);
}
method m($x, $y) {
    $!page.gfx.MoveTo($x, $y);
}

#| Append a straight line segment from the current point to the point (x, y).
#| The new current point is (x, y).
method LineTo($x, $y) {
    $!page.gfx.LineTo($x, $y);
}
method l($x, $y) {
    $!page.gfx.LineTo($x, $y);
}

#| Append a cubic Bézier curve to the current path. The curve extends from the
#| current point to the poit (x3, y3), using (x1, y1) and (x2, y2) as the
#| Bézier control points. The new current point is (x3, y3).
method CurveTo($x1, $y1, $x2, $y2, $x3, $y3) {
    $!page.gfx.CurveTo($x1, $y1, $x2, $y2, $x3, $y3);
}
method c($x1, $y1, $x2, $y2, $x3, $y3) {
    $!page.gfx.CurveTo($x1, $y1, $x2, $y2, $x3, $y3);
}

#| Close the current sub-path by appending a straight line segment from the
#| current point to the starting point of the sub-path.
method ClosePath {
    $!page.gfx.ClosePath;
}
method h {
    $!page.gfx.ClosePath;
}

#| Append a rectangle to the current path as a complete sub-path, with
#| lower-left corner (x, y) and dimensions `width` and `height`.
method Rectangle($x, $y, $width, $Height) {
    $!page.gfx.Rectangle($x, $y, $width, $Height);
}
method re($x, $y, $width, $Height) {
    $!page.gfx.Rectangle($x, $y, $width, $Height);
}

#| Stroke the path.
method Stroke() {
    $!page.gfx.Stroke();
}
method S() {
    $!page.gfx.Stroke();
}

#| Close and stroke the path. Same as: $.Close; $.Stroke
method CloseStroke() {
    $!page.gfx.CloseStroke();
}
method s() {
    $!page.gfx.CloseStroke();
}

#| Fill the path, using the nonzero winding number rule to determine the
#| region. Any open sub-paths are implicitly closed before being filled.
method Fill() {
    $!page.gfx.Fill();
}
method f() {
    $!page.gfx.Fill();
}

#| Fill and then stroke the path, using the nonzero winding number rule to
#| determine the region to fill.
method FillStroke() {
    $!page.gfx.FillStroke();
}
method B() {
    $!page.gfx.FillStroke();
}

#| Close, fill, and then stroke the path, using the nonzero winding number
#| rule to determine the region to fill.
method CloseFillStroke() {
    $!page.gfx.CloseFillStroke();
}
method b() {
    $!page.gfx.CloseFillStroke();
}

#| Modify the current clipping path by intersecting it with the current path,
#| using the nonzero winding number rule to determine which regions lie inside
#| the clipping path.
method Clip() {
    $!page.gfx.Clip();
}
method W() {
    $!page.gfx.Clip();
}

