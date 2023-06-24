use v6.d;

use lib '.';
use lib './lib';

use FunctionalParsers :ALL;
use Test;

# Parsers
# Digit parsers
my &p1 = apply( {1}, symbol('one'));
my &p2 = apply( {2}, symbol('two'));
my &p3 = apply( {3}, symbol('three'));
my &pM = symbol('million');
my &pTh = symbol('things');

# Query
my $query = 'one million things'.words;
my @words = $query.words.List;

plan *;

## 1
is
        alternatives-first-match(&p1, sequence(&p1, &p2))(<one two>).head.head,
        ('two'),
        'just on : one two';

## 2
is
        shortest(alternatives-first-match(&p1, sequence(&p1, &pM)))(<one million things>).head.head,
        ('million', 'things'),
        'shortest first match on : one million things';

## 3
is
        shortest(alternatives-first-match(sequence(&p1, &pM), &p1))(<one million things>).head.head,
        ('things'),
        'shortest first match on : one million things, inverted';

## 4
my &pTest4 = alternatives-first-match(&p1, &p2);
is
        sequence(&pTest4, &pTest4)(<one two>).head.head,
        (),
        'sequence of first match on : one two';

## 5
is
        many1(&pTest4)(<two one>).head.head,
        (),
        'many of first match on : two one';

## 6
is
        many1(&pTest4)(<two one three>).head.head,
        ('three'),
        'many of first match on : two one three';

## 7
my &pTest7 = alternatives-first-match(&p1, sequence(&p1, &p2, &p3));
is
        &pTest7(<one two three>).head.head,
        ('two', 'three'),
        '1 || <1 2 3> of first match on : one two three';

## 8
my &pTest8 = alternatives-first-match(sequence(&p1, &p2, &p3), &p1, &p2);
is
        &pTest8(<one two three>).head.head,
        (),
        '<1 2 3> || 1 of first match on : one two three';

## 9
my &pTest9 = alternatives-first-match(sequence(&p1, &p2), sequence(&p1, &p2, &p3), &p1, &p2);
is
        &pTest9(<one two three>).head.head,
        ('three'),
        '<1 2> || <1 2 3> || 1 of first match on : one two three';

## 10
is-deeply
        alternatives-first-match(sequence(&p1, &p2), sequence(&p1, &p2, &p3), &p1, &p2)(<one two three>),
        ( &p1 «&» &p2 «||» &p1 «&» &p2 «&» &p3 «||» &p1 «||» &p2)(<one two three>),
        'Infix equivalence «||» for: <1 2> || <1 2 3> || 1 of first match on : one two three';

## 11
is-deeply
        alternatives-first-match(sequence(&p1, &p2), sequence(&p1, &p2, &p3), &p1, &p2)(<one two three>),
        ( &p1 ⨂ &p2 ⨁⨁ &p1 ⨂ &p2 ⨂ &p3 ⨁⨁ &p1 ⨁⨁ &p2)(<one two three>),
        'Infix equivalence ⨁⨁ for: <1 2> || <1 2 3> || 1 of first match on : one two three';

## 12
is-deeply
        alternatives-first-match(sequence(&p1, &p2), sequence(&p1, &p2, &p3), &p1, &p2)(<one two three>),
        ( &p1 (&) &p2 (||) &p1 (&) &p2 (&) &p3 (||) &p1 (||) &p2)(<one two three>),
        'Infix equivalence (||) for: <1 2> || <1 2 3> || 1 of first match on : one two three';



done-testing;
