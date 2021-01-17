    #| Text line height
    method TextLeading {
        $!pdf.TextLeading;
    }
    method Tl {
        $!pdf.TextLeading;
    }

    #| Set the stroking colour space to DeviceGray and set the gray level to
    #| use for stroking operations, between 0.0 (black) and 1.0 (white).
    method SetStrokeGray($level) {
        $!pdf.SetStrokeGray($level);
    }
    method G($level) {
        $!pdf.SetStrokeGray($level);
    }

    #| Same as G but used for non-stroking operations.
    method SetFillGray($level) {
        $!pdf.SetFillGray($level);
    }
    method g($level) {
        $!pdf.SetFillGray($level);
    }

    #| Set the stroking colour space to DeviceRGB and set the colour to use
    #| for stroking operations. Each operand is a number between 0.0 (minimum
    #| intensity) and 1.0 (maximum intensity).
    method SetStrokeRGB($r, $g, $b) {
        $!pdf.SetStrokeRGB($r, $g, $b);
    }
    method RG($r, $g, $b) {
        $!pdf.SetStrokeRGB($r, $g, $b);
    }

    #| Same as RG but used for non-stroking operations.
    method SetFillRGB($r, $g, $b) {
        $!pdf.SetFillRGB($r, $g, $b);
    }
    method rg($r, $g, $b) {
        $!pdf.SetFillRGB($r, $g, $b);
    }

    #| Save the current graphics state on the graphics state stack
    method Save() {
        $!pdf.Save();
    }
    method q() {
        $!pdf.Save();
    }

    #| Restore the graphics state by removing the most recently saved state
    #| from the stack and making it the current state.
    method Restore() {
        $!pdf.Restore();
    }
    method Q() {
        $!pdf.Restore();
    }

    #| Set the line width in the graphics state
    method SetLineWidth($width) {
        $!pdf.SetLineWidth($width);
    }
    method w($width) {
        $!pdf.SetLineWidth($width);
    }

    #| Set the line cap style in the graphics state (see LineCap enum)
    method SetLineCap($cap-style) {
        $!pdf.SetLineCap($cap-style);
    }
    method J($cap-style) {
        $!pdf.SetLineCap($cap-style);
    }

    #| Set the line join style in the graphics state (see LineJoin enum)
    method SetLineJoin($join-style) {
        $!pdf.SetLineJoin($join-style);
    }
    method j($join-style) {
        $!pdf.SetLineJoin($join-style);
    }

    #| Set the miter limit in the graphics state
    method SetMiterLimit($ratio) {
        $!pdf.SetMiterLimit($ratio);
    }
    method M($ratio) {
        $!pdf.SetMiterLimit($ratio);
    }

    #| Set the line dash pattern in the graphics state
    method SetDashPattern($dashArray, $dashPhase) {
        $!pdf.SetDashPattern($dashArray, $dashPhase);
    }
    method d($dashArray, $dashPhase) {
        $!pdf.SetDashPattern($dashArray, $dashPhase);
    }

    #| Set the colour rendering intent in the graphics state:
    #| AbsoluteColorimetric, RelativeColormetric, Saturation, or Perceptual
    method SetRenderingIntent($intent) {
        $!pdf.SetRenderingIntent($intent);
    }
    method ri($intent) {
        $!pdf.SetRenderingIntent($intent);
    }

    #| Begin a text object, initializing $.TextMatrix, to the identity matrix.
    #| Text objects cannot be nested.
    method BeginText() {
        $!pdf.BeginText();
    }
    method BT() {
        $!pdf.BeginText();
    }

    #| End a text object, discarding the text matrix.
    method EndText() {
        $!pdf.EndText();
    }
    method ET() {
        $!pdf.EndText();
    }

    #| Move to the start of the next line, offset from the start of the
    #| current line by (tx, ty); where tx and ty are expressed in unscaled
    #| text space units.
    method TextMove($tx, $ty) {
        $!pdf.TextMove($tx, $ty);
    }
    method Td($tx, $ty) {
        $!pdf.TextMove($tx, $ty);
    }

    #| Move to the start of the next line, offset from the start of the
    #| current line by (tx, ty). Set $.TextLeading to ty.
    method TextMoveSet($tx, $ty) {
        $!pdf.TextMoveSet($tx, $ty);
    }
    method TD($tx, $ty) {
        $!pdf.TextMoveSet($tx, $ty);
    }

    #| Move to the start of the next line
    method TextNextLine {
        $!pdf.TextNextLine;
    }
    # alias method 'T*' cannot be used due its invalid identifier in Raku
    #| Show a text string
    method ShowText($string) {
        $!pdf.ShowText($string);
    }
    method Tj($string) {
        $!pdf.ShowText($string);
    }

    #| Move to the next line and show a text string.
    method MoveShowText($string) {
        $!pdf.MoveShowText($string);
    }
    # alias method ''($string)' cannot be used due its invalid identifier in Raku
    #| Move to the next line and show a text string, after setting
    #| $.WordSpacing to aw and $.CharSpacing to ac
    method MoveSetShowText($aw, $ac, $string) {
        $!pdf.MoveSetShowText($aw, $ac, $string);
    }
    # alias method '"($aw, $ac, $string)' cannot be used due its invalid identifier in Raku
    #| Begin a new sub-path by moving the current point to coordinates (x, y),
    #| omitting any connecting line segment. If the previous path construction
    #| operator in the current path was also m, the new m overrides it.
    method MoveTo($x, $y) {
        $!pdf.MoveTo($x, $y);
    }
    method m($x, $y) {
        $!pdf.MoveTo($x, $y);
    }

    #| Append a straight line segment from the current point to the point (x,
    #| y). The new current point is (x, y).
    method LineTo($x, $y) {
        $!pdf.LineTo($x, $y);
    }
    method l($x, $y) {
        $!pdf.LineTo($x, $y);
    }

    #| Append a cubic Bézier curve to the current path. The curve extends from
    #| the current point to the poin (x3, y3), using (x1 , y1) and (x2, y2) as
    #| the Bézier control points. The new current point is (x3, y3).
    method CurveTo($x1, $y1, $x2, $y2, $x3, $y3) {
        $!pdf.CurveTo($x1, $y1, $x2, $y2, $x3, $y3);
    }
    method c($x1, $y1, $x2, $y2, $x3, $y3) {
        $!pdf.CurveTo($x1, $y1, $x2, $y2, $x3, $y3);
    }

    #| Close the current sub-path by appending a straight line segment from
    #| the current point to the starting point of the sub-path.
    method ClosePath {
        $!pdf.ClosePath;
    }
    method h {
        $!pdf.ClosePath;
    }

    #| Append a rectangle to the current path as a complete sub-path, with
    #| lower-left corner (x, y) and dimensions `width` and `height`.
    method Rectangle($x, $y, $width, $Height) {
        $!pdf.Rectangle($x, $y, $width, $Height);
    }
    method re($x, $y, $width, $Height) {
        $!pdf.Rectangle($x, $y, $width, $Height);
    }

    #| Stroke the path.
    method Stroke() {
        $!pdf.Stroke();
    }
    method S() {
        $!pdf.Stroke();
    }

    #| Close and stroke the path. Same as: $.Close; $.Stroke
    method CloseStroke() {
        $!pdf.CloseStroke();
    }
    method s() {
        $!pdf.CloseStroke();
    }

    #| Fill the path, using the nonzero winding number rule to determine the
    #| region. Any open sub-paths are implicitly closed before being filled.
    method Fill() {
        $!pdf.Fill();
    }
    method f() {
        $!pdf.Fill();
    }

    #| Fill and then stroke the path, using the nonzero winding number rule to
    #| determine the region to fill.
    method FillStroke() {
        $!pdf.FillStroke();
    }
    method B() {
        $!pdf.FillStroke();
    }

    #| Close, fill, and then stroke the path, using the nonzero winding number
    #| rule to determine the region to fill.
    method CloseFillStroke() {
        $!pdf.CloseFillStroke();
    }
    method b() {
        $!pdf.CloseFillStroke();
    }

    #| Modify the current clipping path by intersecting it with the current
    #| path, using the nonzero winding number rule to determine which regions
    #| lie inside the clipping path.
    method Clip() {
        $!pdf.Clip();
    }
    method W() {
        $!pdf.Clip();
    }

