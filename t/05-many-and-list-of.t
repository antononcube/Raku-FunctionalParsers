use v6.d;

use lib '.';
use lib './lib';

use FunctionalParsers;
use Test;

# Digit parsers
my @intNames = <zero one two three four five six seven eight nine ten>;
my @pDigits = (@intNames Z ^10).map(-> $p { apply({ $p[1] }, symbol($p[0])) });

# Parser with non-atomic interpretation
my &p1 = apply( {[1, 'one']}, symbol('one'));
my &p2 = apply( {[2, 'two']}, symbol('two'));
my &p3 = apply( {[3, 'three']}, symbol('three'));
my &p4 = apply( {[4, 'four']}, symbol('four'));

# Separator
my &sep = alternatives(symbol(','), symbol('and'));

# Query
my $query = 'one million things'.words;
my @words = $query.words.List;

plan *;

## 1
is
        many(alternatives(@pDigits))('one four three one'.words).head.tail,
        (1, 4, 3, 1),
        'many on : one four three one';


## 2
is
        many(alternatives(@pDigits))('one'.words).head.tail,
        (1),
        'many on : one';

## 3
is
        many(alternatives(@pDigits))(''.words).head.tail,
        (),
        'many on : nothing';


## 4
is
        many(alternatives(&p1, &p2, &p3, &p4))('one two three four'.words).head.tail,
        ([1, 'one'], [2, 'two'], [3, 'three'], [4, 'four']),
        'many on : one two three four';

## 5
my $res = many1(alternatives(@pDigits))('one four three one'.words).head.tail;
is
        $res.elems,
        4,
        'many1 on : one four three one - elems';
## 6
is
        $res,
        (1, 4, 3, 1),
        'many1 on : one four three one';

## 7
is
        many1(alternatives(&p1, &p2, &p3, &p4))('one two three four'.words).head.tail,
        ([1, 'one'], [2, 'two'], [3, 'three'], [4, 'four']),
        'many1 on : one two three four';

## 8
is
        list-of(alternatives(@pDigits), &sep)('one, four, three and one'.split(/<wb> | \s/, :skip-empty)).head.tail,
        (1, 4, 3, 1),
        'list of on : one, four, three and one';


## 8
is
        list-of(alternatives(@pDigits), &sep)(['one',]).head.tail,
        (1,),
        'list of on : one';

done-testing;
