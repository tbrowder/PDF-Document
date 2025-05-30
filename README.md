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

Module `PDF::Document` leverages the power of lower-level modules `PDF::Lite`, `FontFactory`, and `FontFactory::Type1` and encapsulates some of its classes, routines, and variables into higher-level contructs to ease PDF document creation.

PDF document generation process
-------------------------------

This module is designed around the document generation process used by those who use PostScript (PS) code to create PS documents which are then transformed into PDF by the GNU program `ps2pdf`. That process is described in great detail in the classic PS books by Adobe (see REFERENCES).

The same sequence is also followed in the PDF document creation process:

  * Define the `PDF::Lite` class instance (a heavy-weight instantiation, only one per document)

        my $pdf = PDF::Lite;

  * Select the fonts (with size) to be used with either (1) the `FontFactory` or (2) the `FontFactory::Type1` or both. The advantage of (1) is the fonts are usually TrueType or OpenType with large numbers of Unicode glyphs. Any Type 1 fonts ('.t1') available may have more glyphs available than the fonts in (2). (There are 72 PS points per inch.)

        my $ff    = FontFactory.new;
        my $fft   = FontFactory::Type1.new: # uses PDF::Lite to access standard fonts
        my $t12d1 = $fft.get-font: 't12d1'  # Times-Roman at 12.1 points
        my $c10   = $fft.get-font: 'c10';   # Courier at 10 points
        my $ft1   = $ff.get-font: :name(), :size();
        my $ft2   = $ff.get-font: :index(), :size();

  * Define each page

        my $page = $pdf.add-page;
        #...add text and graphics...
        #...add a new page...
        my $page = $pdf.add-page;
        #...add text and graphics...

  * Create the document and exit

        $pdf.save-as<MyDoc.pdf>;

Summary
-------

As you can see the document steps are equivalent, but the steps in PDF page creation are much easier because common low-level code required in PS creation is available under the covers in `PDF::Lite` and accessed more easily by this module.

CURRENT CAPABILITY
==================

Currently the the module provides routines and constants as used in the example program shown in the **SYNOPSIS**. In addition, other graphics and text examples are shown in the `/dev` directory including showing phases of the Moon, creating grids, using landscape orientation, and using A4 paper.

There is also a font factory which eases selection and use of multiple fonts. Fonts included are all the standard PostScript fonts plus a font used to create bank checks: **MICREncoding**. The PS fonts are free for any use, but the MICR font is only free for non-commercial use. See its **license.txt** file in the `/dev/fonts/micr/unzipped` directory.

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

  * `CheckWriter`

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

