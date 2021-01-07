[![Actions Status](https://github.com/tbrowder/PDF-Document/workflows/test/badge.svg)](https://github.com/tbrowder/PDF-Document/actions)

NAME
====

`PDF::Document` - Provides high-level classes and routines to create original documents in Portable Document Format (PDF)

SYNOPSIS
========

```raku
use PDF::Document;
for %CoreFonts.kv -> $fontname, $fontalias {
    say "Font family: '$fontname' (alias: '$fontalias')";
}
# output:
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

That sequence is followed in the PDF document creation process:

  * Define the PDF class instance (a heavy-weight instanciation, only one per document)

    * `my $pdf = PDF::Lite;`

  * Find the fonts to be used (also a heavy-weight instanciation)

    * `my $courier = find-font :fontfamily<Courier>, :$pdf;`

  * Select the fonts to be used by adding size to a copy of an existing font face (a light-weight instanciation) 

    * `my $c10 = select-font :$fontfamily, :size(10);`

  * Define each page

    * `my $page = $pdf.add-page;`

    * `#...add text and graphics...`

    * `my $page = $pdf.add-page;`

    * `#...add text and graphics...`

  * Create the document and exit

    * `$pdf.save-as<MyDoc.pdf>;`

As you can see the steps are equivalent, but the steps in PDF page creation are much easier because common low-level code required in PS creation is available behind the covers in PDF::Lite and accessed more easily by this module.

REFERENCES
==========



  * Adobe 3

  * Adobe Cookbook

AUTHOR
======

Tom Browder <tbrowder@cpan.org>

COPYRIGHT AND LICENSE
=====================

Copyright © 2021 Tom Browder

This library is free software; you can redistribute it or modify it under the Artistic License 2.0.

