#!/usr/bin/env raku

use lib <./lib ../lib>;
use PDF::Document;

show-corefonts;

say "Showing aliases as keys:";
say "  $_" for %CoreFontAliases.keys.sort;

