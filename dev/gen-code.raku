#!/usr/bin/env raku

use Text::Utils :strip-comment, :wrap-paragraph;

my $ifil  = 'pdf-methods-of-interest.from-pod';
my $ifil2 = 'afm-methods-of-interest.from-pod';

my $debug = 0;

my $meth  = 1;
my $test  = 0;
my $role  = 0;
my $doc   = 0;
my $all   = 0;

if !@*ARGS {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.IO.basename} meth | test | role | doc | all [debug]

    Parses files '$ifil'
    and '$ifil2' to
    extract methods and their aliases and builds
    various Raku code products that use them.

    It also generates a test file to check each
    method and alias.
    HERE

    exit;
}

sub z{$meth=$all=$test=$doc=$role=0}
for @*ARGS {
    # options
    when /^de/ { $debug  = 1 }
    # modes
    when /^d/  { z; $doc  = 1 }
    when /^m/  { z; $meth = 1 }
    when /^t/  { z; $test = 1 }
    when /^a/  { z; $all  = 1 }
    # end modes
    default    { z; $meth = 1 }
}

my $of1 = "pdf-methods.auto-generated";
my $of2 = "00-pdf-methods.t";

my $of3 = "PDF-role.rakumod";
my $of4 = "AFM-role.rakumod";

my $fh  = open $of, :w;
my $fh2 = open $of2, :w;

# Some alias methods will not work due to syntax
# conflicts with Raku identifiers
my %no-alias = set < MoveShowText MoveSetShowText TextNextLine >;
# These tests are used with other tests so we don't 
# test them individually:
my %no-test = set < Save Restore BeginText EndText >;
# Some methods need special handling (context) in tests
# Outside of a text block, these need to between BeginText/EndText pairs 
my %need-BT-ET = set < TextMove TextMoveSet TextNextLine ShowText MoveShowText MoveSetShowText >;
# These need to be between Save/Restore pairs
my %need-q-Q = set < SetStrokeGray SetFillGray SetStrokeRGB SetFillRGB SetLineWidth SetLineCap SetLineJoin SetMiterLimit >;

# Set up the test file
$fh2.say: q:to/HERE/;
#================================================================
#
# THIS FILE IS AUTO-GENERATED - EDITS MAY BE LOST WITHOUT WARNING
#
#================================================================
use Test;
use File::Temp;
use PDF::Document;
plan 37;
# global vars
my ($of, $fh) = tempfile;
my ($doc, $x, $y);
$doc = Doc.new;
HERE

my $nm  = 0; # num methods written
my $na  = 0; # num alias methods written
my $nmt = 0; # num method tests written
my $nat = 0; # num method alias tests written
my $test-num = 0; # for the test file

class PMeth {
    # methods in the PDF::API6 list
    has $.meth       is rw;
    has $.alias      is rw;
    has $.full-meth  is rw;
    has $.full-alias is rw;
    has $.desc       is rw;
    has @.args       is rw;
    has $.spec       is rw;
}

class FMeth {
    # methods in the Font::AFM list
}

my @pmethods = get-pdf-methods $ifil, :$debug;
write-pdf-methods $of1, @pmethods, :$debug;
write-pdf-method-tests $of2, @pmethods, :$debug;

say qq:to/HERE/;

Normal end.
Generated $nm methods and $na alias methods.
Generated $nmt method tests and $nat alias method tests.
See output files:
  $of1
  $of2
HERE

exit;

# getters
sub get-afm-methods() {
}
# writers
sub write-font-methods() {
}
sub write-afm-method-tests() {
}
sub write-pdf-role() {
}
sub write-afm-role() {
}
sub write-document-module() {
}

sub get-pdf-methods($ifil, :$debug --> List) {
    my @pmeths;
    for $ifil.IO.lines -> $line is copy {
        $line = strip-comment $line;
        next if $line !~~ /\S/;

        my $m = PMeth.new;

        ++$nm;
        my @w  = split '|', $line;
        my $w1 = @w.shift.trim;
        my $w2 = @w.shift.trim;
        my $desc = @w.shift.trim;
        say "$w1 => $w2" if $debug;

        # gen two methods
        # the method may have args or may have empty or no sig parens
        # the alias will have none on input
        my $meth;         # meth name
        my $empty-parens; # just the ()
        my $sig;          # text inside parens

        # input
        my $tmp-full-meth = $w1; # meth + sig WITHOUT $sigils
        my $alias         = $w2; # alias name
        $m.alias = $alias;

        # we need several strings to represent the various parts in
        # the methods file and the test file:
        #
        # method:
        #    method foo($a) {  # <-- meth + sig inside parens --> $full-meth
        #        self.foo($a)  # <-- same as above
        #    }
        #    method bar() {    # <-- meth + empty parens --> $full-meth
        #        self.bar()    # <-- same as above
        #    }
        # test:
        #    # test N
        #    lives-ok {
        #        my $a = 0:
        #        $doc.foo($a)           # <-- meth + sig inside parens
        #    }, "testing method 'foo'"; # <-- meth only --> $meth
        #
        #    # test N+1
        #    lives-ok {
        #        $doc.bar()             # <-- meth + empty parens
        #    }, "testing method 'bar'"; # <-- meth only

        if $w1 ~~ /(<[A..Za..z_0..9]>+) \h*         # $0
                   [('(' \h* ')')    # $1
                     ||
                    ('(') (.*) (')') # $1 $2 $3
                   ]? / {
            $meth = ~$0;
            $m.meth = $meth; # no parens or sig
            note "DEBUG: parse found \$0: '$meth'" if $debug;
            if $1.defined {
                my $c = ~$1;
                note "DEBUG: parse found \$1: '$c'" if $debug;
                if $2.defined and $3.defined {
                    # $2 it's the sig inside the parens
                    $sig = ~$2;
                    note "DEBUG: parse found \$2: '$sig'" if $debug;
                    my $c2 = ~$3;
                    note "DEBUG: parse found \$3: '$c2'" if $debug;
                }
                else {
                    note "DEBUG: parse found empty parens" if $debug;
                    $empty-parens = '()';
                }
            }
        }
        else {
            note "DEBUG: parse failed on meth '$w1'...skipping" if $debug;
            next;
        }

        my $full-meth;
        my $full-alias;
        my @args;
        my $use-alias = True;
        if $sig.defined {
            $sig ~~ s:g/','//;
            my @w = $sig.words;
            for @w -> $w {
                my $a = "\$$w";
                @args.push: $a;
            }
            $sig = '(' ~ join(', ', @args) ~ ')';

            $full-meth  = $meth  ~ $sig;
            $full-alias = $alias ~ $sig;
        }
        elsif $empty-parens.defined {
            $full-meth  = $meth  ~ $empty-parens;
            $full-alias = $alias ~ $empty-parens;
        }
        else {
            $full-meth  = $meth;
            $full-alias = $alias;
        }

        if $meth.defined and %no-alias{$meth}:exists {
            $use-alias = False;
        }

        # may need other special handling
        my $spec = '';
        if $meth.defined and %need-BT-ET{$meth}:exists {
            $spec = 'BT';
        }
        elsif $meth.defined and %need-q-Q{$meth}:exists {
            $spec = 'q';
        }

        # complete the PMeth object
        $m.full-meth  = $full-meth;
        $m.full-alias = $full-alias;
        $m.args       = @args;
        $m.desc       = $desc;
        $m.spec       = $spec;

        @pmeths.push: $m;

        #===================================================
        # AT THIS POINT WE HAVE CAPTURED ALL METHOD INFO AND
        # CAN SEPARATE THIS INTO AT LEAST TWO SUBS: 
        #   READER of pmethods
        #   WRITER of tests
        #   WRITER of copy/paste class Doc methods
        #   WRITER of PDF roles
        #===================================================

    }
    return @pmeths;
} # end reader

sub write-pdf-method-tests($ofil, @pmethods) {
}

sub write-pdf-methods($ofil, @pmethods, :$debug) {
      for @pmethods -> $m {

        # write the description for the method
        my @p = wrap-paragraph $m.desc.words, :para-pre-text('#| '), :para-indent(4);

        $fh.say: $_ for @p;
        $fh.print: qq:to/HERE/;
            method {$m.full-meth} \{
                \$!page.gfx.{$m.full-meth};
            }
        HERE

        if $use-alias {
            ++$na;
            # in all cases we will make the alias call the real method
            $fh.say: qq:to/HERE/;
                method $full-alias \{
                    \$!page.gfx.{$full-meth};
                }
            HERE
        }
        else {
            $fh.say: "    # alias method '$full-alias' cannot be used due its invalid identifier in Raku";
        }
    }
    $fh.close;
}

sub write-pdf-method-tests($ofil, @pmethods) {
        # THIS BEGINS A NEW SUB FOR WRITING PDF METHOD TESTS
        # expand args to add values
        #my $arg-vals = expand-args @args, $meth;
        my $arg-vals = expand-args $m.args, $m.meth;

        
        # some tests aren't needed as a standalone test
        #next if %no-test{$meth}:exists;
        next if %no-test{$m.meth}:exists;

        # write lives-ok tests
        ++$nmt;
        # may need special handling
        $fh2.print: qq:to/HERE/;
        # test {++$test-num}
        lives-ok \{
        HERE
        $fh2.say("    \$doc.BT;") if $spec eq 'BT';
        $fh2.say("    \$doc.q;") if $spec eq 'q';
        $fh2.say($arg-vals) if $arg-vals;
        $fh2.say("    \$doc.{$m.full-meth};");
        $fh2.say("    \$doc.ET;") if $spec eq 'BT';
        $fh2.say("    \$doc.Q;") if $spec eq 'q';
        $fh2.say("}, \"testing method '{$m.meth}'\";");

        next if not $use-alias;

        ++$nat;

        $fh2.print: qq:to/HERE/;
        # test {++$test-num}
        lives-ok \{
        HERE
        $fh2.say("    \$doc.BT;") if $spec eq 'BT';
        $fh2.say("    \$doc.q;") if $spec eq 'q';
        $fh2.say("$arg-vals") if $arg-vals;
        $fh2.say("    \$doc.{$m.full-alias};");
        $fh2.say("    \$doc.ET;") if $spec eq 'BT';
        $fh2.say("    \$doc.Q;") if $spec eq 'q';
        $fh2.say("}, \"testing method '{$m.meth}', alias '{$m.alias}'\";");
    }
    $fh.close;
}


sub get-val($a, $meth?) {
    my $val;
    given $a {
        when /:i ^ '$' [r|g|b] $/ {
            $val = 0.5
        }
        when /:i level/ {
            $val = 0.5
        }
        when /:i style / {
            $val = 1
        }
        when /:i ratio / {
            $val = 0.5
        }
        when /:i array / {
            $val = 0.5
        }
        when /:i phase / {
            $val = 0.5
        }
        when /:i string / {
            $val = '"some text"'
        }
        when /:i width / {
             $val = 5
        }

        default {
             $val = 100
        } # position
    }

    if $meth eq 'SetDashPattern' {
        $val = '"some text"'
    }
    elsif $meth eq 'SetRenderingIntent' {
        $val = '"some text"'
    }
    return $val;
}

sub expand-args(@args, $meth?) {
    # expand args to add values
    # my $arg-vals = expand-args @args)
    my $s = '';
    return $s unless @args;

    for @args -> $a is copy {
        my $val = get-val $a, $meth;
        $s ~= '    my ' ~ $a;
        $s ~= " = $val;\n";
    }
    $s .= trim-trailing;
    return $s;
}
