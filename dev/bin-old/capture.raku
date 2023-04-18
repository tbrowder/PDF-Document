#!/usr/bin/env raku

if not @*ARGS {
    say qq:to/HERE/;
    Usage:  {$*PROGRAM.IO.basename} go

    Test a capture usage for a wrapped sub as
        a proof of concept.
    HERE
    exit;
}

wrapping 1, :b(2), :c<d>;

sub wrapping($a, |c) { # 
    my %a;
    for c.kv -> $k, $v {
        say "key '$k' => '$v'";
        %a{$k} = $v;
    }
    say "the \%a hash:";
    say %a.raku;
    say "the incoming capture:";
    say c.Capture.raku;
    say "the unpacked incoming capture:";
    say %a.Capture;

    my $e = %a.Capture;
    my @d = wrapped $a, :position[100,200], |$e; 
    say "returned list from wrapped:";
    say @d.raku;
}

sub wrapped($a, :$position, *%args) {
    return $position, "c";
}


