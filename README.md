[![Actions Status](https://github.com/tbrowder/PDF-Document/workflows/test/badge.svg)](https://github.com/tbrowder/PDF-Document/actions)

NAME
====

`PDF::Document` - Provides high-level classes and routines to create original documents in Portable Document Format (PDF)

SYNOPSIS
========

```raku
use PDF::Document;
my \d = Doc.new; 

# this sets the following defaults:
#   :paper<Letter>, :font<t11d5> (Times-Roman 11.5)
#   line spacing (:leading) 1.3 * font size
#   margins lm<1n>, rm<1in>, tm<1in>, bm<1in>
#   origin now at botton-left corner
#   x=0 at the left margin, increases to the right
#   y=0 at the bottom margin, increases upward
#   current position top left corner, one line down
#   long lines are wrapped with left justification (ragged right)
#   text is kerned
# begin writing...

d.text "2021-03-04";
d.nl 1; # set currentpoint x=0,y one line down from top-left corner
d.text "Dear Mom,";
d.nl 2; # resets x=0
d.text "I am fine.";

# end the page
d.mvto :br; # bottom-right corner
d.rmvto :y(-2 * d.leading); 
d.text "Page 1", :rj; # right justified

d.np; start # new page

d.mvto :tl; # top-left corner
d.nl 1; # set currentpoint x=0,y one line down from top-left corner

d.text q:to/PARA/;
A VERY long para
PARA

d.nl 2;
d.text "Love,";
d.nl 2; 
d.text "Isaiah";

# end the page
d.mvto :br; # bottom-right corner
d.rmvto :y(-2 * $leading); 
d.text "Page 2 of 2", :rj; # right justified
d.save "letter.pdf";
```

DESCRIPTION
===========

Module `PDF::Document` leverages the power of lower-level modules `PDF::Lite` and `Font::AFM` and encapsulates some of its classes, routines, and variables into higher-level contructs to ease PDF document creation.

PostScript document generation process
--------------------------------------

The module is designed around the document generation process used by those who use PostScript (PS) code to create PS documents which are then transformed into PDF by the GNU program `ps2pdf`. That process is described in great detail in the classic PS books by Adobe (see REFERENCES) and is divided into the following logical sequences:

  * Define the prologue which usually includes:

    * Finding the font faces to be used

    * Font selection (creating the actual font by scaling a face to the desired size)

    * Procedure definition

  * Define and render each page

  * End the document

### PostScript font selection

The PS font selection process needs a little more detail to help explain how it is done in this module. First some terminology. From Ref. 1 we get some pertinent function names and definitions:

  * **findfont** - *key* **findfont** *font* - "obtains a font dictionary defined by the *key* and pushes it on the operand stack...", p. 418

  * **scalefont** - *font scale* **scalefont** *font'* - "applies the scale factor *scale* to *font*, producing a new *font'* whose characters are scaled by *scale* (in both *x* and *y*) when they are shown.", p. 488

  * **setfont** - *font* **setfont** *-* - "establishes the font dictionary parameter in the graphics state.", p. 503

  * **selectfont **[Level 2]**** - *key scale* **scalefont** - "obtains a font whose name is *key*, transforms is according to *scale*, and establishes it as the current font dictionary in the graphics state.", p. 490

The PS Level 1 method for defining a usable font is shown in this example:

    /Times-Roman findfont 10 scalefont setfont

The PS Level 2 method for defining a usable font is shown in this example:

    /Times-Roman 10 selectfont

(Note the the Level 2 method is "almost always more efficient.", Ref. 1, p. 490)

In either case, we usually save desired combinations of font prototypes and scale by defining them by another name for easy recall. For example:

    /h12 /Helvetica 10 selectfont def
    /hb12 /Hevetica-Bold 12 selectfont def

Now we can use them like this:

    hb12 (Cowboy slang: ) show
    h10 (Howdy, podnuh!) show

Which would generate something like this in the final document: "**Cowboy slang:** Howdy, podnuh!"

PDF document generation process
-------------------------------

That sequence is also followed in the PDF document creation process:

  * Define the `PDF` class instance (a heavy-weight instantiation, only one per document)

    * `my $pdf = PDF::Lite;`

  * Find the fonts to be used (also a heavy-weight instantiation)

    * `my $courier = find-font :name<Courier>, :$pdf;`

    * `my $helvetica` = find-font :name<h>, :$pdf; # use its alias>

  * Select the fonts to be used by adding size to a copy of an existing font family (a light-weight instantiation)

    * `my $c10 = select-font :fontfamily($courier), :size(10);`

    * `my $h12h= select-font :fontfamily($helvetica`, :size(12.5);>

  * Define each page

    * `my $page = $pdf.add-page;`

    * `#...add text and graphics...`

    * `#...add a new page...`

    * `my $page = $pdf.add-page;`

    * `#...add text and graphics...`

  * Create the document and exit

    * `$pdf.save-as<MyDoc.pdf>;`

### PDF font selection

As opposed to PS, the font selection process using `PDF::Lite` is a bit different since, with the given low-level routines, we keep the font "prototype" separate from the desired font size when we use the font in a text block. For example, here is a text block being rendered on a PDF page instance:

```raku
$page.text: {
    .text-position = $x, $y;
    .font = $setfont.font, $setfont.size;
    .say("Howdy, podnuh!");
}
```

Summary
-------

As you can see the document steps are equivalent, but the steps in PDF page creation are much easier because common low-level code required in PS creation is available behind the covers in `PDF::Lite` and accessed more easily by this module.

CURRENT CAPABILITY
==================

Currently the only thing the module provides are routines and data to ease acces to PDF core fonts (those shown in the listing above) in a using module.

FUTURE CAPABILITY
=================

This module is being used during the development of the author's other PDF modules:

  * `PDF::Writer`*

  * `PDF::Labelmaker`**

  * `PDF::Calendar`

  * `PDF::ReWriter`

  * `PDF::Forms`

This module will be updated with more items as the user modules are updated and published.

NOTE: The asterisk (`*`) indicates the module has been published. Two asterisks means the published module is not even minimally useful, but it is exposed to issues or feature requests from interested parties.

REFERENCES
==========



  * 1. *PostScript Language Reference Manual*, 2nd Edition, Adobe Systems Inc., 1990

  * 2. *PostScript Language Tutorial and Cookbook*, Adobe Systems Inc., 1986

AUTHOR
======

Tom Browder <tbrowder@cpan.org>

COPYRIGHT and LICENSE
=====================

Copyright © 2021 Tom Browder

This library is free software; you can redistribute it or modify it under the Artistic License 2.0.

