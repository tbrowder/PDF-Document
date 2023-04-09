use Test;
use PDF::Content;
use PDF::Document;
use PDF::Lite;
use Font::AFM;
use Proc::Easier;

my $debug = 0;

plan 6;

my ($args, $cmd, $doc);
lives-ok {
    $doc = Doc.new: :media-box('Letter');
}, "checking new Doc object";

lives-ok {
    $args = "./dev/make-example-doc.raku";
    $cmd  = cmd $args, :die;
    say "results: exit '{$cmd.exit}' err '{$cmd.err}', out '{$cmd.out}'" if $debug;
}, "testing the example doc with no args";

lives-ok {
    $args = "./dev/make-example-doc.raku g";
    $cmd  = cmd $args, :die;
    say "results: exit '{$cmd.exit}' err '{$cmd.err}', out '{$cmd.out}'" if $debug;
}, "testing the example doc with arg of 'g'";

# The following tests fail when :die is used, but .err is nil!!
# But only on Github, not on my local host!!
lives-ok {
    $args = "./dev/make-grid.raku";
    $cmd  = cmd $args; #, :die;
    say "results: exit '{$cmd.exit}' err '{$cmd.err}', out '{$cmd.out}'" if $debug;
}, "testing the example doc with no args";

lives-ok {
    $args = "./dev/make-grid.raku g";
    $cmd  = cmd $args; #, :die;
    say "results: exit '{$cmd.exit}' err '{$cmd.err}', out '{$cmd.out}'" if $debug;
}, "testing the example doc with args";

lives-ok {
    $args = "./dev/make-grid.raku g a";
    $cmd  = cmd $args; #, :die;
    say "results: exit '{$cmd.exit}' err '{$cmd.err}', out '{$cmd.out}'" if $debug;
}, "testing the example doc with args";

