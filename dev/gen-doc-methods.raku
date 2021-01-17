#!/usr/bin/env raku

use Text::Utils :strip-comment, :wrap-paragraph;

my $ifil = 'pdf-methods-of-interest.from-pod';

my $debug = 0;
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
$doc = Doc.new;
HERE


my $nm  = 0; # num methods written
my $na  = 0; # num alias methods written
my $nmt = 0; # num method tests written
my $nat = 0; # num method alias tests written
my $test-num = 0; # for the test file

for $ifil.IO.lines -> $line is copy {
    $line = strip-comment $line;
    next if $line !~~ /\S/;

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

    # write the description also
    my @p = wrap-paragraph $desc.words, :para-pre-text('#| '), :para-indent(4);
    $fh.say: $_ for @p;
    $fh.print: qq:to/HERE/;
        method $full-meth \{
            \$!pdf.$full-meth;
        }
    HERE

    if $use-alias {
        ++$na;
        # in all cases we will make the alias call the real method
        $fh.say: qq:to/HERE/;
            method $full-alias \{
                \$!pdf.$full-meth;
            }
        HERE
    }
    else {
        $fh.say: "    # alias method '$full-alias' cannot be used due its invalid identifier in Raku";
    }

    # expand args to add values
    my $arg-vals = expand-args @args;

    # write lives-ok tests 
    ++$nmt;
    $fh2.print: qq:to/HERE/;
    # test {++$test-num}
    lives-ok \{
    HERE
    $fh2.say($arg-vals) if $arg-vals;
    $fh2.say: qq:to/HERE/;
        \$doc.$full-meth
    }, "testing method '$meth'";
    HERE

    next if not $use-alias;
    
    ++$nat;
    $fh2.print: qq:to/HERE/;
    # test {++$test-num}
    lives-ok \{
    HERE
    $fh2.say("$arg-vals") if $arg-vals;
    $fh2.say: qq:to/HERE/;
        \$doc.$full-alias
    }, "testing method '$meth', alias '$alias'";
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


