use v6.d;

use lib '.';
use lib './lib';

use FunctionalParsers;
use Test;

# Parsers
my &p1 = symbol('one');
my &p2 = symbol('two');
my &p3 = symbol('three');
my &p4 = symbol('four');
my &pM = symbol('million');
my &pTh = symbol('things');

# Query
my $query = 'one million things'.words;
my @words = $query.words.List;

plan *;

## 1
ok token('one')($query.comb);

## 2
ok sequence(&p1, &pM)(@words);

## 3
ok alternatives(&p1, &p2)(@words);

## 4
ok sequence(alternatives(&p1, &p2), &pM)(@words);

done-testing;