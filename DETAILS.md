Some details
============

Fonts
-----

In this module we have three classes representing a font:

### 1. `$rawfont` 

An instance of a PDF::Lite "prototype" font. It is what the text blocks require for rendering text.

### 2. `BaseFont` 

A class that holds the `$rawfont` object as well as an instance of its Font::AFM object with the rawfont's metrics.

### 3. `DocFont`

A class representing the user-level font which marries the rawfont and the desired size. It also has methods from the Font::AFM object. Those methods that return metrics of the rawfont are scaled to produce the exact values for the font at its size.

Document generation methods
---------------------------

There are two planned modes of document generation:

### 1. Text to PDF

This is the first method to be implemented, and it is in very rudimentary form. It takes a plain text document and, line by line, renders it int PDF. It is suitable for turning code into printed output with features such as:

  * line numbering

  * line wrapping

  * page numbering

  * bottom or top margin file naming

### 2. Pod to PDF

Using Pod markup as input the rendered PDF will look more like a polished, typeset document with many ways to style and format the finished product.

Font factory
------------

As an aid to the user of this module, there is a FontFactory class that can be used to keep track of the fonts used and avoid duplicate font generation instances.

The first requirement is to enforce strict naming rules. We recognize two lists of names for the base fonts available. The first list contains the names as keys in the %CoreFonts hash. The second is the names of the aliases of those fonts which are at most three characters long and are the keys of the %CoreFontAliases hash.

Final DocFont keys are formed from the alias of the desired font followed by the integer of the font size. So a Times-Roman font set at 14 points would have a key if `t14`. If the user needs a fractional font size the size would have the letter 'd' separating the intergral and fractional part. For example, a Helvetica font set at 12.4 pts would have a key of 'h12d4'. The following code shows initialization of a PDF document:

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

