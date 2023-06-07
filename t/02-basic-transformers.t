use v6.d;

use lib '.';
use lib './lib';

use FunctionalParsers :set, :ALL;
use Test;

# Parsers
# Digit parsers
my &p1 = apply( {1}, symbol('one'));
my &pM = symbol('million');
my &pTh = symbol('things');

# Query
my $query = 'one million things'.words;
my @words = $query.words.List;

plan *;

## 1
is &p1(['one',]).head.tail, 1, 'apply for "one"';

## 2
is sp(&p1)([' ', ' ', 'one']).head.tail, 1, 'parse " one"';

## 3
is sp(&p1)(['', '', 'one']).head.tail, 1, 'parse " one"';

## 4
is
        just(alternatives(&p1, sequence(&p1, &pM)))(<one million>).head.head,
        (),
        'just on : one million';

## 5
is
        shortest(alternatives(&p1, sequence(&p1, &pM)))(<one million things>).head.head,
        ('things'),
        'shortest on : one million things';

done-testing;
