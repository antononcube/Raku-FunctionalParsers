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
my &pt4 = ((&p1 (|) &p2 (|) &p3 (|) &p4) (&) (&pM (^) {10**6}) (<&) &pTh) (^) {[*] $_};
is &pt4('three million things'.words).head.tail, 3_000_000;

done-testing;
