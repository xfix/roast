use v6;

# L<S32::IO/IO/=item say>

# doesn't use Test.pm and plan() intentionally

say "1..8";

# Tests for say
{
    say "ok 1 - basic form of say";
}

{
    say "o", "k 2 - say with multiple parame", "ters (1)";

    my @array = ("o", "k 3 - say with multiple parameters (2)");
    say |@array;
}

{
    my $arrayref = <ok 4 - say stringifies its args>;
    say $arrayref;
}

{
    "ok 5 - method form of say".say;
}

#?niecza emit if 0 {

$*OUT.say('ok 6 - $*OUT.say(...)');
#?niecza emit }

#?niecza emit say 'ok 6 - #SKIP Cannot cast from source type to destination type.';

#?niecza emit if 0 {
"ok 7 - Mu.print\n".print;
#?niecza emit }

#?niecza emit say 'ok 7 - #SKIP method .print not found in Str';

grammar A {
    token TOP { .+ };
}

#?niecza emit if 0 {
#?pugs   emit if 0 {
A.parse("ok 8 - Match.print\n").print;
#?niecza emit }
#?pugs   emit }

#?niecza emit say 'ok 8 - #SKIP method .print not found in Match';
#?pugs   emit say 'ok 8 - #SKIP method .print not found in Match';

# vim: ft=perl6
