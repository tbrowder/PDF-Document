### method TextLeading

```perl6
method TextLeading() returns Mu
```

Text line height

### method SetStrokeGray

```perl6
method SetStrokeGray(
    $level
) returns Mu
```

Set the stroking colour space to DeviceGray and set the gray level to use for stroking operations, between 0.0 (black) and 1.0 (white).

### method SetFillGray

```perl6
method SetFillGray(
    $level
) returns Mu
```

Same as G but used for non-stroking operations.

### method SetStrokeRGB

```perl6
method SetStrokeRGB(
    $r,
    $g,
    $b
) returns Mu
```

Set the stroking colour space to DeviceRGB and set the colour to use for stroking operations. Each operand is a number between 0.0 (minimum intensity) and 1.0 (maximum intensity).

### method SetFillRGB

```perl6
method SetFillRGB(
    $r,
    $g,
    $b
) returns Mu
```

Same as RG but used for non-stroking operations.

### method Save

```perl6
method Save() returns Mu
```

Save the current graphics state on the graphics state stack

### method Restore

```perl6
method Restore() returns Mu
```

Restore the graphics state by removing the most recently saved state from the stack and making it the current state.

### method SetLineWidth

```perl6
method SetLineWidth(
    $width
) returns Mu
```

Set the line width in the graphics state

### method SetLineCap

```perl6
method SetLineCap(
    $cap-style
) returns Mu
```

Set the line cap style in the graphics state (see LineCap enum)

### method SetLineJoin

```perl6
method SetLineJoin(
    $join-style
) returns Mu
```

Set the line join style in the graphics state (see LineJoin enum)

### method SetMiterLimit

```perl6
method SetMiterLimit(
    $ratio
) returns Mu
```

Set the miter limit in the graphics state

### method BeginText

```perl6
method BeginText() returns Mu
```

Begin a text object, initializing $.TextMatrix, to the identity matrix. Text objects cannot be nested.

### method EndText

```perl6
method EndText() returns Mu
```

End a text object, discarding the text matrix.

### method TextMove

```perl6
method TextMove(
    $tx,
    $ty
) returns Mu
```

Move to the start of the next line, offset from the start of the current line by (tx, ty); where tx and ty are expressed in unscaled text space units.

### method TextMoveSet

```perl6
method TextMoveSet(
    $tx,
    $ty
) returns Mu
```

Move to the start of the next line, offset from the start of the current line by (tx, ty). Set $.TextLeading to ty.

### method TextNextLine

```perl6
method TextNextLine() returns Mu
```

Move to the start of the next line

### method ShowText

```perl6
method ShowText(
    $string
) returns Mu
```

Show a text string

### method MoveShowText

```perl6
method MoveShowText(
    $string
) returns Mu
```

Move to the next line and show a text string.

### method MoveSetShowText

```perl6
method MoveSetShowText(
    $aw,
    $ac,
    $string
) returns Mu
```

Move to the next line and show a text string, after setting $.WordSpacing to aw and $.CharSpacing to ac

### method MoveTo

```perl6
method MoveTo(
    $x,
    $y
) returns Mu
```

Begin a new sub-path by moving the current point to coordinates (x, y), omitting any connecting line segment. If the previous path construction operator in the current path was also m, the new m overrides it.

### method LineTo

```perl6
method LineTo(
    $x,
    $y
) returns Mu
```

Append a straight line segment from the current point to the point (x, y). The new current point is (x, y).

### method CurveTo

```perl6
method CurveTo(
    $x1,
    $y1,
    $x2,
    $y2,
    $x3,
    $y3
) returns Mu
```

Append a cubic Bézier curve to the current path. The curve extends from the current point to the poit (x3, y3), using (x1, y1) and (x2, y2) as the Bézier control points. The new current point is (x3, y3).

### method ClosePath

```perl6
method ClosePath() returns Mu
```

Close the current sub-path by appending a straight line segment from the current point to the starting point of the sub-path.

### method Rectangle

```perl6
method Rectangle(
    $x,
    $y,
    $width,
    $Height
) returns Mu
```

Append a rectangle to the current path as a complete sub-path, with lower-left corner (x, y) and dimensions `width` and `height`.

### method Stroke

```perl6
method Stroke() returns Mu
```

Stroke the path.

### method CloseStroke

```perl6
method CloseStroke() returns Mu
```

Close and stroke the path. Same as: $.Close; $.Stroke

### method Fill

```perl6
method Fill() returns Mu
```

Fill the path, using the nonzero winding number rule to determine the region. Any open sub-paths are implicitly closed before being filled.

### method FillStroke

```perl6
method FillStroke() returns Mu
```

Fill and then stroke the path, using the nonzero winding number rule to determine the region to fill.

### method CloseFillStroke

```perl6
method CloseFillStroke() returns Mu
```

Close, fill, and then stroke the path, using the nonzero winding number rule to determine the region to fill.

### method Clip

```perl6
method Clip() returns Mu
```

Modify the current clipping path by intersecting it with the current path, using the nonzero winding number rule to determine which regions lie inside the clipping path.

