use v6.d;

use lib '.';
use lib './lib';

use FunctionalParsers :shortcuts;
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
is-deeply
        seq(&p1, &pM)(@words),
        sequence(&p1, &pM)(@words),
        "seq";

## 2
is-deeply
        alt(&p1, &p2)(@words),
        alternatives(&p1, &p2)(@words),
        "alt";

## 3
is-deeply
        seq(alt(&p1, &p2), &pM)(@words),
        sequence(alternatives(&p1, &p2), &pM)(@words),
        "seq(alst)";

## 4
is-deeply
        seql(&p1, &p2)(<one two>).head,
        ((), 'one'),
        "seql one two";

## 5
is-deeply
        seqr(&p1, &p2)(<one two>).head,
        ((), 'two'),
        "seqr one two";

## 6
is-deeply
        sp(seq(&p3,&pM))([" ",  " ", "three", "million"]),
        (((),('three', 'million')),),
        'sp(seq)';


done-testing;
