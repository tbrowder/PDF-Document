#!/usr/bin/env raku

use lib <./lib ../lib>;
use PDF::Document;

my $frac;
my $diam;
my $type;  # wax or wane
my $hemi  = 'n';
my $angle = 0;
my $ofil  = 0;
my $debug = 0;
my $test  = 0;
if not @*ARGS {
    say qq:to/HERE/;
    Usage:  {$*PROGRAM.IO.basename} args... [options...]

    Creates a PDF Moon phase image for the given inputs:

    Arguments:
        frac=F   - F is the fraction of illumination
        diam=D   - D is the desired image diameter in inches
        wax|wane - The half of the Lunar month desired

    Options:
        angle=A  - A is the crescent angle in degrees from the
                     observer's "up" direction (default: 0)
        hemi=H   - H is 'n' or 's', the Northern or Southern
                     Hemisphere (the observer's location, default: 'n')
        ofil=O   - O is the output file name; default:
                     'Moon-phase-F-D-W-A-H.pdf'
        debug    - For developer use
        test     - For developer use
    HERE
    exit;
}


for @*ARGS {
    when /^:i de/                                 { $debug = 1   }
    when /^:i a <[ngle]>? '=' (\d+ ['.' \d+]?) $/ { $angle = +$0 }
    when /^:i h <[emi]>?  '=' (n|s) $/            { $hemi  = ~$0 }
    when /^:i o <[fil]>?  '=' (\S+) $/            { $ofil  = ~$0 }
    when /^:i wax $/                              { $type = 'wax' }
    when /^:i wan <[e]>? $/                       { $type = 'wane' }
    when /^:i f <[rac]>? '=' (0? '.' \d+) $/      { $frac = +$0 }
    when /^:i d <[iametr]>? '=' (\d+ ['.' \d+]?) $/ { $diam = +$0 }
    when /^:i t $/ {
        $angle = 0;
        $hemi = 'n';
        $type = 'wax';
        $frac = 0.3;
        $diam = 1;
    }
    default {
        note "FATAL: Unknown arg '$_'";
        exit;
    }
}

my $err = 0;
if not $frac.defined {
        note "FATAL: 'frac' has not been entered";
        ++$err;
}
elsif not (0 <= $frac <= 1) {
        note "FATAL: 'frac' is not in the range [0..1] (frac = $frac)";
        ++$err;
}

if not $diam.defined {
        note "FATAL: 'diam' has not been entered";
        ++$err;
}
elsif not (0 < $diam) {
        note "FATAL: 'diam' is not greater than zero (diam = $diam)";
        exit;
}
if not $type.defined {
        note "FATAL: 'neither 'wax' nor 'wane' was entered";
        ++$err;
}
if $err {
    note "Error exit.";
    exit;
}

if not $ofil {
    # generate a name by parts
    my $p = 'Moon-phase';
    my $f = sprintf "%0.2f", $frac;
    my $d = sprintf "%0.2f", $diam;
    my $t = $type;
    my $a = sprintf "%0.2f", $angle;
    my $h = $hemi;
    $ofil = "{$p}-{$f}F-{$d}D-{$t}T-{$a}A-{$h}H.pdf";
}

if 0 {
    note "DEBUG exit: ofil = '$ofil'";
    exit;
}
# We change only three of the many defaults for this
# example: (1) output file name, (2) force option to
# allow overwriting that file if it exists, and (3)
# turn page numbering on:
my \d = Doc.new: :pdf-name($ofil), :force, :$debug;

# use the 'with' block to ease typing by one character
# per command
# but you'll crash if you forget to close the block!
my $radius = 0.5 * $diam * i2p; # points
my $cx = $radius; # points
my $cy = $cx; # points

note "DEBUG: moon-phase: cx = $cx, cy = $cy, radius = $radius, frac = $frac, type = $type" if $debug;
d.moon-phase: :$cx, :$cy, :$radius, :$frac, :type<wan>, :hemi<s>, :$angle;


d.end-doc; # renders the pdf and saves the output
