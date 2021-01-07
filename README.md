[![Actions Status](https://github.com/tbrowder/PDF-Document/workflows/test/badge.svg)](https://github.com/tbrowder/PDF-Document/actions)

NAME
====

`PDF::Document` - Provides high-level classes and routines to create original documents in Portable Document Format (PDF)

SYNOPSIS
========

```raku
use PDF::Document;
show-corefonts;
```

Produces:

```raku
Font family: 'Courier'               (alias: 'c')
Font family: 'Courier-Bold'          (alias: 'ch')
Font family: 'Courier-BoldOblique'   (alias: 'cbo')
Font family: 'Courier-Oblique'       (alias: 'co')
Font family: 'Helvetica'             (alias: 'h')
Font family: 'Helvetica-Bold'        (alias: 'hb')
Font family: 'Helvetica-BoldOblique' (alias: 'hbo')
Font family: 'Helvetica-Oblique'     (alias: 'ho')
Font family: 'Symbol'                (alias: 's')
Font family: 'Times-Bold'            (alias: 'tb')
Font family: 'Times-BoldItalic'      (alias: 'tbi')
Font family: 'Times-Italic'          (alias: 'ti')
Font family: 'Times-Roman'           (alias: 't')
Font family: 'Zapfdingbats'          (alias: 'z')
```

DESCRIPTION
===========

Module `PDF::Document` leverages the power of lower-level modules `PDF::Lite` and `Font::AFM` and encapsulates some of its classes, routines, and variables into higher-level contructs to ease PDF document creation.

It is designed around the document generation process used by those who use PostScript (PS) code to create PS documents which are then transformed into PDF by the GNU program `ps2pdf`. That process is described in great detail in the classic PS books by Adobe (see REFERENCES) and is divided into the following logical sequences:

  * Define the prologue which usually includes:

    * Finding the font faces to be used

    * Font selection (creating the actual font by scaling a face to the desired size)

    * Procedure definition

  * Define and render each page

  * End the document

That sequence is also followed in the PDF document creation process:

  * Define the `PDF` class instance (a heavy-weight instantiation, only one per document)

    * `my $pdf = PDF::Lite;`

  * Find the fonts to be used (also a heavy-weight instantiation)

    * `my $courier = find-font :fontfamily<Courier>, :$pdf;`

  * Select the fonts to be used by adding size to a copy of an existing font family (a light-weight instantiation)

    * `my $c10 = select-font :fontfamily($courier), :size(10);`

  * Define each page

    * `my $page = $pdf.add-page;`

    * `#...add text and graphics...`

    * `#...add a new page...`

    * `my $page = $pdf.add-page;`

    * `#...add text and graphics...`

  * Create the document and exit

    * `$pdf.save-as<MyDoc.pdf>;`

As you can see the steps are equivalent, but the steps in PDF page creation are much easier because common low-level code required in PS creation is available behind the covers in `PDF::Lite` and accessed more easily by this module.

CURRENT CAPABILITY
==================

Currently the only thing the module provides are routines and data to ease acces to PDF core fonts (those shown in the listing above) in a using module.

FUTURE CAPABILITY
=================

This module is being used during the development of the author's other PDF modules:

  * `PDF::Writer`*

  * `PDF::Labelmaker`

  * `PDF::Calendar`

  * `PDF::ReWriter`

  * `PDF::Forms`

This module will be updated with more items as the user modules are updated and published.

NOTE: The asterisk (`*`) indicates the module has been published.

REFERENCES
==========



  * *PostScript Language Reference Manual*, 2nd Edition, Adobe Systems Inc., 1990

AUTHOR
======

Tom Browder <tbrowder@cpan.org>

COPYRIGHT and LICENSE
=====================

Copyright © 2021 Tom Browder

This library is free software; you can redistribute it or modify it under the Artistic License 2.0.

