Some developer details
======================

Fonts
-----

In this module we have three classes representing a font:

### 1. `$rawfont`

An instance of a `PDF::Lite` *prototype* font. It is what the text blocks require for rendering text.

### 2. `BaseFont`

A class that holds the `$rawfont` object as well as an instance of its `Font::AFM` object with the `$rawfont`'s metrics.

### 3. `DocFont`

A class representing the user-level font which marries the `$rawfont` and the desired size. It also has methods from the `Font::AFM` object. Those methods that return metrics of the `$rawfont` are scaled to produce the exact values for the font at its size.

Document generation methods
---------------------------

There are three planned modes of document generation:

### 1. Text to PDF

This requires users to write a Raku program and use methods to write their document. This method is being developed now and approximates the original PostScript methods. The main purpose of this method being first is to get the PDF methods understood, simplified, and integrated into the main class for managing a document, the `Doc` class.

### 2. Text to PDF (with text input)

This will be the first text-input method to be implemented, and it is in very rudimentary form. It takes a plain text document and, line by line, renders it into PDF. It is suitable for quickly putting text files into printed form for such uses as code printouts. It has features such as:

  * line numbering

  * line wrapping

  * page numbering

  * bottom or top margin file naming

### 3. Pod to PDF (with Pod text file input)

Using Pod markup as input, the rendered PDF will look more like a polished, typeset document with many ways to style and format the finished product.

Font factory
------------

As an aid to the user of this module, there is a `FontFactory` class that can be used to keep track of the fonts used and avoid duplicate font generation instances.

The first requirement is to enforce strict naming rules. We recognize two lists of names for the base fonts available. The first list contains the names as keys in the `%CoreFonts` hash. The second is the names of the aliases of those fonts which are at most three characters long and are the keys of the `%CoreFontAliases` hash.

Final `DocFont` keys are formed from the alias of the desired font followed by the integer of the font size. So a Times-Roman font face set at 14 points would have a key of `t14`. If the user needs a fractional font size, the size would have the letter `d` separating the integral and fractional parts. For example, a Helvetica font face set at 12.4 pts would have a key of `h12d4`. The following code shows initialization of a PDF document:

```raku
use PDF::Lite;
use Font::AFM;
use PDF::Document;

my $pdf = PDF::Lite.new;
my $pdf.media-box = "Letter";
my $ff = FontFactory.new: :$pdf;

# use a 12 point Times-Roman font
my $t12 = $ff.set-font<t12>;
# get another of the same
my $T12 = $ff.set-font<T12>;
# case is not significant, so the same font
# is requested, so the factory quietly
# returns a copy of the same instance.
```

PDF methods and their aliases ("codes")
=======================================

Adobe has short names for many of their methods. The following tables show many of those exposed by the `Doc` class.

<table class="pod-table">
<caption>Color Operators</caption>
<thead><tr>
<th>Method</th> <th>Alias</th> <th>Description</th> <th>Default</th> <th>Example Setter</th>
</tr></thead>
<tbody>
<tr> <td>Color operators</td> <td></td> <td></td> <td></td> <td></td> </tr> <tr> <td>SetStrokeGray</td> <td>G</td> <td></td> <td></td> <td></td> </tr> <tr> <td>SetFillGray</td> <td>g</td> <td></td> <td></td> <td></td> </tr> <tr> <td>SetStrokeRGB</td> <td>RG</td> <td></td> <td></td> <td></td> </tr> <tr> <td>SetFillRGB</td> <td>rg</td> <td></td> <td></td> <td></td> </tr>
</tbody>
</table>

<table class="pod-table">
<caption>Graphics State</caption>
<thead><tr>
<th>Method</th> <th>Alias</th> <th>Description</th> <th>Default</th> <th>Example Setter</th>
</tr></thead>
<tbody>
<tr> <td>TextLeading</td> <td>Tl</td> <td>text line height</td> <td></td> <td></td> </tr> <tr> <td>SetLineWidth</td> <td>w</td> <td></td> <td></td> <td></td> </tr> <tr> <td>SetLineCap</td> <td>J</td> <td></td> <td></td> <td></td> </tr> <tr> <td>SetLineJoin</td> <td>j</td> <td></td> <td></td> <td></td> </tr> <tr> <td>Save</td> <td>q</td> <td></td> <td></td> <td></td> </tr> <tr> <td>Restore</td> <td>Q</td> <td></td> <td></td> <td></td> </tr>
</tbody>
</table>

<table class="pod-table">
<caption>Text Operators</caption>
<thead><tr>
<th>Method</th> <th>Alias</th> <th>Description</th> <th>Default</th> <th>Example Setter</th>
</tr></thead>
<tbody>
<tr> <td>BeginText</td> <td>BT</td> <td></td> <td></td> <td></td> </tr> <tr> <td>EndText</td> <td>ET</td> <td></td> <td></td> <td></td> </tr> <tr> <td>TextMove</td> <td>Td</td> <td></td> <td></td> <td></td> </tr> <tr> <td>TextMoveSet</td> <td>TD</td> <td></td> <td></td> <td></td> </tr> <tr> <td>TextNextLine</td> <td>T*</td> <td></td> <td></td> <td></td> </tr> <tr> <td>ShowText</td> <td>Tj</td> <td></td> <td></td> <td></td> </tr> <tr> <td>MoveShowText</td> <td>&#39;</td> <td></td> <td></td> <td></td> </tr> <tr> <td>MoveSetShowText</td> <td>&quot;</td> <td></td> <td></td> <td></td> </tr>
</tbody>
</table>

<table class="pod-table">
<caption>Path Construction</caption>
<tbody>
<tr> <td>Method</td> <td>Alias</td> <td>Description</td> <td>Default</td> <td>Example Setter</td> </tr> <tr> <td>MoveTo</td> <td>m</td> <td></td> <td></td> <td></td> </tr> <tr> <td>LineTo</td> <td>l</td> <td></td> <td></td> <td></td> </tr> <tr> <td>CurveTo</td> <td>c</td> <td></td> <td></td> <td></td> </tr> <tr> <td>ClosePath</td> <td>h</td> <td></td> <td></td> <td></td> </tr> <tr> <td>Rectangle</td> <td>re</td> <td></td> <td></td> <td></td> </tr> <tr> <td>Fill</td> <td>f</td> <td></td> <td></td> <td></td> </tr> <tr> <td>Stroke</td> <td>S</td> <td></td> <td></td> <td></td> </tr> <tr> <td>Clip</td> <td>W</td> <td></td> <td></td> <td></td> </tr>
</tbody>
</table>

