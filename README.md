[![Actions Status](https://github.com/tbrowder/PDF-Document/actions/workflows/linux.yml/badge.svg)](https://github.com/tbrowder/PDF-Document/actions) [![Actions Status](https://github.com/tbrowder/PDF-Document/actions/workflows/macos.yml/badge.svg)](https://github.com/tbrowder/PDF-Document/actions) [![Actions Status](https://github.com/tbrowder/PDF-Document/actions/workflows/windows.yml/badge.svg)](https://github.com/tbrowder/PDF-Document/actions)

WARNING - A WORK IN PROGRESS - EXPECT CHANGES
=============================================

NAME
====

**PDF::Document** - Provides high-level classes and routines to create original documents in Portable Document Format (PDF)

This module is currently functioning as a laboratory to create routines and classes to support other PDF modules. As such, its API is subject to change until version 1.0.0+.

In the meantime, users are encouraged to use it, report issues, and submit feature requests.

See the `dev` directory in the source repository for examples of use. The example in the **SYNOPSIS** is program `./dev/make-example-doc.raku`.

SYNOPSIS
========

```raku
#!/usr/bin/env raku
use PDF::Document;

# We change only three of the many defaults for this
# example: (1) output file name, (2) force option to
# allow overwriting that file if it exists, and (3)
# turn page numbering on:
my \d = Doc.new: :pdf-name<example-letter>, :force, :page-numbering, :$debug;

#=========== THE LETTER =================
# starts with a new page, current position top baseline, left margin

# put the date at the top-right corner
d.print: "2021-03-04", :tr, :align<right>, :valign<top>;
d.nl; # adds the newline, resets x to left margin, moves y down one line

d.say: "Dear Mom,"; # SHOULD automatically add a newline
d.nl: 1; # moves y down one line, resets x=0 (left margin)
d.say: "I am fine.";
d.nl: 1;
d.say: "How are you?";

# simple graphics: circle, etc.
d.nl: 30;
d.say: "circle: radius = 36 pts, linewidth = 4 points";
d.save; # save the current position and graphics state
d.setlinewidth: 4; # points
d.circle: :x<5in>, :y<3in>, :radius(36); # default points (or in, cm)
d.restore; # don't forget to go back to normal!

d.np; # new page, current position top baseline, left margin
d.say: q:to/PARA/;
Pretend this is a VERY long para
that extends at least more than one line length in the
current font so we can observe the effect of  paragraph
wrapping. Isn't this swell!
PARA

d.nl: 3;

d.say: "Thats all, folks, but see following pages for other bells and whistles!";
d.nl: 2;
d.say: "Love,";
d.nl: 2;
d.say: "Isaiah";

d.np; # for some graphics examples

d.say: "ellipse: a = 1 in, b = 0.5 in", :y<8in>;
d.ellipse: :x<5in>, :y<8in>, :a<1in>, :b<.5in>;

d.say: "ellipse: a = 0.3 in, b = 2 cm", :y<6in>;
d.ellipse: :x<5in>, :y<6in>, :a<.3in>, :b<2cm>;

d.say: "circle: radius = 24 mm", :y<4in>;
d.circle: :x<5in>, :y<4in>, :radius<24mm>;

d.say: "rectangle: width = 2 in, height = 2 cm", :y<2in>;
d.rectangle: :llx<5in>, :lly<2in>, :width<2in>, :height<2cm>;

d.np; # for some more graphics examples

d.say: "polyline:", :y<7.5in>;
my @pts = 1*i2p, 7*i2p, 4*i2p, 6.5*i2p, 3*i2p, 5*i2p;
d.polyline: @pts;


d.say: "blue polygon:", :y<4.5in>;
@pts = 1*i2p, 4*i2p, 4*i2p, 3.5*i2p, 3*i2p, 2*i2p;
d.polygon: @pts, :fill, :color[0,0,1]; # rgb, 0-1 values


d.end-doc; # renders the pdf and saves the output
          # also numbers the pages if you requested it
#=========== END THE LETTER =================
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

  * **selectfont **[Level 2]**** - *key scale* **scalefont** - "obtains a font whose name is *key*, transforms is according to *scale*, and establishes it as the current font dictionary in the graphics state.", p. 490

The PS Level 2 method for defining a usable font is shown in this example:

    /Times-Roman 10 selectfont

(Note the the Level 2 method is "almost always more efficient.", Ref. 1, p. 490)

We usually save desired combinations of font prototypes and scale by defining them by another name for easy recall. For example:

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

As opposed to PS, the font selection process using `PDF::Lite` is a bit different since, with the given low-level routines, we keep the font "prototype" separate from the desired font size when we use the font in a text block. For example, here is a text block being rendered on a PDF page instance with the fonts defined previously:

```raku
$page.text: {
    .text-position = $x, $y;
    .font = $c10.font, $c10.size;
    .say("Howdy, podnuh!");
}
```

Summary
-------

As you can see the document steps are equivalent, but the steps in PDF page creation are much easier because common low-level code required in PS creation is available under the covers in `PDF::Lite` and accessed more easily by this module.

CURRENT CAPABILITY
==================

Currently the the module provides routines and constants as used in the example program shown in the **SYNOPSIS**. In addition, other graphics and text examples are shown in the `/dev` directory including showing phases of the Moon, creating grids, using landscape orientation, and using A4 paper.

More work is planned including:

  * font underlining

  * font strikethrough

FUTURE CAPABILITY
=================

This module is being used during the development of the author's other PDF modules:

  * `PDF::Writer`*

  * `PDF::Labelmaker`**

  * `PDF::Calendar`

  * `PDF::ReWriter`

  * `PDF::Forms`

This module will be updated with more items as the user modules are updated and published.

NOTE: The asterisk (`*`) indicates the module has been published, albeit of minimal use. Two asterisks means the published module is not even minimally useful, but it is exposed to issues or feature requests from interested parties.

CREDITS
=======



The author is indebted to the tremendous amount of work done by his Raku friend, David Warring. David's voluminous project, hosted at [https://github.com/PDF-Raku](https://github.com/PDF-Raku), provides all the tools needed to manipulate PDF files using our wonderful Raku language. Thank you David!

REFERENCES
==========



##### 1. *PostScript Language Reference Manual* (the "Red Book"), 2nd Edition, Adobe Systems Inc., 1990

##### 2. *PostScript Language Tutorial and Cookbook* (the "Blue Book"), Adobe Systems Inc., 1986

AUTHOR
======

Tom Browder <tbrowder@acm.org>

COPYRIGHT and LICENSE
=====================

Copyright © 2021-2023 Tom Browder

This library is free software; you may redistribute it or modify it under the Artistic License 2.0.

