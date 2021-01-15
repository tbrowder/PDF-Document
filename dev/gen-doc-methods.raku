#!/usr/bin/env raku

use Text::Utils :strip-comment, :wrap-paragraph;

my $f = 'pdf-methods-of-interest.list';

if !@*ARGS {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.IO.basename} go

    Parses file '$f' to extract methods and their
    aliases and builds that portion of the Doc
    class.
    HERE

    exit;
}

my $ofil = "pdf-methods.rakumod";
my $fh = open $ofil, :w;

my $n = 0;

# some alas methods will not work due to syntax conflicts with Raku identifiers
my %no-alias = set <
MoveShowText
MoveSetShowText
TextNextLine
>;

for $f.IO.lines -> $line is copy {
    $line = strip-comment $line;
    next if $line !~~ /\S/;

    ++$n;
    my @w = split '|', $line;
    my $w1 = @w.shift.trim;
    my $w2 = @w.shift.trim;
    my $desc = @w.shift.trim;
    say "$w1 => $w2";



    # gen two methods
    # the first method may have args
    my $sig;
    my $use-alias = 1;
    my $meth;
    if $w1 ~~ /(\S+) \h* '(' (.*)  ')' / {
        $meth = ~$0;
        # it's the sig
        $sig = ~$1;
        $sig ~~ s:g/','//;
        my @w = $sig.words;
        my @args;
        for @w -> $w {
            my $a = "\$$w";
            @args.push: $a;
        }
        $sig = '(' ~ join(', ', @args) ~ ')';
        $w1 = $meth ~ $sig;
        $w2 ~= $sig;
    }
    if $meth.defined and %no-alias{$meth}:exists {
        $use-alias = 0;
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


    =begin comment
    # the second will not have a sig but it must be added if the first has it
    if $sig.defined {
        $fh.say: qq:to/HERE/;
            method $w2$sig \{
                \$!pdf.{$w2};
            }
        HERE
    }
    else {
        $fh.say: qq:to/HERE/;
            method $w2 \{
                \$!pdf.$w2;
            }
        HERE
    }
    =end comment

}
$fh.close;
say "\nSee output file '$ofil'";
say "Generated $n methods plus the same number of alias methods.";
