use v6.d;

use lib '.';
use lib './lib';

use FunctionalParsers :set, :ALL;
use Test;

# Parsers
my &p1 = apply( {1}, symbol('one'));
my &p2 = apply( {2}, symbol('two'));
my &p3 = apply( {3}, symbol('three'));
my &p4 = apply( {4}, symbol('four'));
my &pM = symbol('million');
my &pTh = symbol('things');

# Query
my $query = 'one million things'.words;
my @words = $query.words.List;

plan *;

## 1
is &p1('one'.words.List).head.tail, 1, 'parse one';

## 2
is &p4('four'.words.List).head.tail, 4, 'parse four';

## 3
my &pt3 = (&p1 (|) &p2 (|) &p3 (|) &p4) (&) &pM (&) &pTh;
is &pt3('three million things'.words).head.tail, (3, 'million', 'things');

## 4
my &pt4 = (&p1 (|) &p2 (|) &p3 (|) &p4) (&) (&pM (^) {10**6}) (&) &pTh;
is &pt4('three million things'.words).head.tail, (3, 1_000_000, 'things');

## 5
my &pt5 = ((&p1 (|) &p2 (|) &p3 (|) &p4) (&) (&pM (^) {10**6}) (<&) &pTh) (^) {[*] $_};
is &pt5('three million things'.words).head.tail, 3_000_000;

## 6
# Higher precedence of «o compared to «|»
my &pt6 = &p1 «|» &p2 «|» &p3 «o {$_**2}
is &pt6('three'.words).head.tail, 9;

## 7
# Higher precedence of «o compared to «&»
my &pt7 = {$_ ** 2} ⨀ &p2 ⨂ &p4 ⨂ &p3;
is &pt7('two four three'.words).head.tail, (4, 4, 3);

## 8
# Higher precedence of «&» compared to «o
my &pt8 = {$_.flat>>.Str.join.Int ** 2} ⨀ (&p2 ⨂ &p4 ⨂ &p3);
is &pt8('two four three'.words).head.tail, (243 ** 2);

## 9
# Listable «|»
my &pt9 = &p1 «|» &p2 «|» &p3 «|» &p4;
is-deeply many(&pt9)('two four three one'.words).head.tail, (2, 4, 3, 1);

## 10
# Listable «&»
my &pt10 = &p2 «&» &p4 «&» &p3 «&» &p1;
is-deeply &pt10('two four three one'.words).head.tail, (2, (4, (3, 1)));

## 11
# Listable «&»
my &pt11 = sequence(&p2, &p4, &p3, &p1);
is-deeply &pt11('two four three one'.words).head.tail, (2, (4, (3, 1)));

done-testing;
