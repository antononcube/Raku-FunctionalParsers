#!/usr/bin/env raku
use v6.d;

use lib '.';
use lib './lib';

use FunctionalParsers;

my $query = 'one million things'.words;
my @words = $query.words.List;

my &p1 = symbol('one');
my &p2 = symbol('two');
my &p3 = symbol('three');
my &p4 = symbol('four');
my &pM = symbol('million');
my &pTh = symbol('things');

my @intNames = <zero one two three four five six seven eight nine ten>;
#my @pDigits = (@intNames Z ^10).map({ symbol($_[0]) });
#note (@intNames Z ^10);
my @pDigits = (@intNames Z ^10).map( -> $p { apply({$p[1]}, symbol($p[0])) });

my &pDigit = alt(@pDigits);

#note @pDigits;

#`[
say &p1(@words).raku;

say token('one')($query.comb).raku;

say seq-comp(&p1, &pM)(@words).raku;

say alt-comp(&p1, &p2)(@words).raku;

say seq-comp(alt-comp(&p1, &p2), &pM)(@words).raku;
]

#say seq-comp(alt-comp(&p1, &p2), &pM)(@words).raku;

say '=' x 120;

#say seq(alt(&p1, &p2), &pM, &pT)(@words);
#say ((&p1 (|) &p2 (|) &p3 (|) &p4) «&» &pM «&» &pT)(@words);
say (alt(@pDigits) «&» &pM «&» &pTh)(@words);

say @intNames.map({ alt(@pDigits)([$_,]) }).raku;

say '=' x 120;

#my &pN = apply( {[*] $_}, seq(alt(apply({1}, &p1), apply({2}, &p2)), apply({10**6}, &pM)));
#my &pN = apply( {[*] $_}, seq(alt(apply({1}, &p1), apply({2}, &p2)), apply({10**6}, &pM)));
#my &pN = apply( {[*] $_}, alt(@pDigits) (&) apply({10**6}, &pM));
#my &pN = apply( {[*] $_}, seq(alt(@pDigits), {10**6} «o» &pM));
my &pN = ( &pDigit «&» &pM «o {10**6}) «o {[*] $_};

say &pN('two million'.words);

say &pN('four million'.words);

say (&pDigit «& satisfy({ $_ ~~ / \w+ /}))("two things".words);

my &pTest1 = (&pDigit «&» &pM «o {10**6}) «o {[*] $_} «|» &pDigit «& &pTh;
say &pTest1("two things".words);
say just(&pTest1)("two things".words);
say just(&pTest1)("two million".words);
say sp(&pTest1)([" ",  " ", "three", "million"]);
