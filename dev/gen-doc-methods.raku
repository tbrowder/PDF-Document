#!/usr/bin/env raku

use Text::Utils :strip-comment, :wrap-paragraph;

my $ifil = 'pdf-methods-of-interest.from-pod';

if !@*ARGS {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.IO.basename} go

    Parses file '$ifil' to 
    extract methods and their aliases and builds 
    that portion of the Doc class.

    It also generates a test file to check each
    method and alias.
    HERE

    exit;
}

my $of  = "pdf-methods.rakumod";
my $of2 = "pdf-methods.t";
my $fh  = open $of, :w;
my $fh2 = open $of2, :w;

# Some alias methods will not work due to syntax 
# conflicts with Raku identifiers
my %no-alias = set <
    MoveShowText
    MoveSetShowText
    TextNextLine
>;

# Set up the test file
$fh2.say: q:to/HERE/;
use Test;
use File::Temp;

use PDF::Document;

# plan N; # enter correct N after all desired tests pass

# global vars
my ($of, $fh) = tempfile;
my ($doc, $x, $y);
HERE


my $nm  = 0; # num methods written
my $na  = 0; # num alias methods written
my $nmt = 0; # num method tests written
my $nat = 0; # num method alias tests written

for $ifil.IO.lines -> $line is copy {
    $line = strip-comment $line;
    next if $line !~~ /\S/;

    ++$nm;
    my @w  = split '|', $line;
    my $w1 = @w.shift.trim;
    my $w2 = @w.shift.trim;
    my $desc = @w.shift.trim;
    say "$w1 => $w2";

    # gen two methods
    # the first method may have args or may have empty or no sig parens
    my $meth;         # meth name
    my $empty-parens; # just the ()
    my $sig;          # text inside parens

    my @args;
    my $use-alias = True;
    my $W1;
    my $W2 = $w2;
    if $w1 ~~ /(\S+) \h*         # $0
               [('(' \h* ')')    # $1
                 || 
                ('(') (.*) (')') # $1 $2 $3
               ]? / {
        $meth = ~$0;
        $W1 = $meth;

        if $1.defined {
            if $2.defined and $3.defined {
                # $2 it's the sig inside the parens
                $sig = ~$2;
            }
            else {
                $empty-parens = '()';
            }
        }
    }

    if $sig.defined {
        $sig ~~ s:g/','//;
        my @w = $sig.words;
        for @w -> $w {
            my $a = "\$$w";
            @args.push: $a;
        }
        $sig = '(' ~ join(', ', @args) ~ ')';
        $w1 = $meth ~ $sig;
        $w2 ~= $sig;
    }

    if $meth.defined and %no-alias{$meth}:exists {
        $use-alias = False;
    }

    # write the description also
    my @p = wrap-paragraph $desc.words, :para-pre-text('#| '), :para-indent(4);
    $fh.say: $_ for @p;
    $fh.print: qq:to/HERE/;
        method $w1 \{
            \$!pdf.$w1;
        }
    HERE

    if $use-alias {
        ++$na;
        # in all cases we will make the alias call the real method
        $fh.say: qq:to/HERE/;
            method $w2 \{
                \$!pdf.$w1;
            }
        HERE
    }
    else {
        $fh.say: "    # alias method '$w2' cannot be used due its invalid identifier in Raku";
    }

    # expand args to add values
    my $arg-vals = expand-args @args;

    # write lives-ok tests 
    ++$nmt;
    $fh2.print: qq:to/HERE/;
    lives-ok \{
    HERE
    $fh2.say($arg-vals) if $arg-vals;
    $fh2.say: qq:to/HERE/;
        $w1
    }, "testing method '$W1'";
    HERE

    next if not $use-alias;
    
    ++$nat;
    $fh2.print: qq:to/HERE/;
    lives-ok \{
    HERE
    $fh2.say("$arg-vals") if $arg-vals;
    $fh2.say: qq:to/HERE/;
        $w2
    }, "testing method '$W1', alias '$W2'";
    HERE

}
$fh.close;
$fh2.close;

say qq:to/HERE/;

Normal end.
Generated $nm methods and $na alias methods.
Generated $nmt method tests and $nat alias method tests.
See output files:
  $of
  $of2
HERE

sub get-val($a, $m?) {
    given $a {
        when /:i ^ '$' [r|g|b]$/ { 
            0.5 
        }
        when /:i level/ { 
            0.5 
        }
        when /:i style / {
            1 
        }
        when /:i ratio / { 
            0.5 
        }
        when /:i array / {
            0.5 
        }
        when /:i phase / {
            0.5 
        }
        when /:i string / {
            '"some text"' 
        }
        when /:i width / {
             5 
        }

        default {
             100 
        } # postion
    }
}

sub expand-args(@args) {
    # expand args to add values
    # my $arg-vals = expand-args @args)
    my $s = '';
    return $s unless @args;

    for @args -> $a is copy {
        my $val = get-val $a;
        $s ~= '    my ' ~ $a;
        $s ~= " = $val;\n";
    }
    $s .= trim-trailing;
    return $s;
}


