use v6;
use Test;
plan 48;

# L<S29/Num/"=item exp">

=begin pod

Basic tests for the exp() builtin

=end pod

#?rakudo skip 'named args'
{
    is_approx(exp(:exponent(5)), 148.4131591025766, 'got the exponent of 5');
    is_approx(exp(:exponent(0)), 1, 'exp(:exponent(0)) == 1');

    is_approx(exp(:exponent(1i*pi)), -1, 'exp(:exponent(i pi)) == -1');
    is_approx(exp(:exponent(-1i*pi)), -1, 'exp(:exponent(-i pi)) == -1');
}

is_approx(exp(5), 148.4131591025766, 'got the exponent of 5');
is_approx(exp(0), 1, 'exp(0) == 1');

is_approx(exp(1i*pi), -1, 'exp(i pi) == -1');
is_approx(exp(-1i*pi), -1, 'exp(-i pi) == -1');

{
    for 1 .. 20 {
	    my $arg = 2.0 * pi / $_;
	    is_approx(exp(1i * $arg), cos($arg) + 1i * sin($arg), 'expi == cos + i sin No. ' ~ $_);
	    is_approx(exp(1i * $arg) * exp(-1i * $arg), 1, 'exp(ix) * exp(-ix) == 1 No. ' ~ $_);
    }
}
# vim: ft=perl6
