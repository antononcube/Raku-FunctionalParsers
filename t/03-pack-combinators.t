use v6.d;

use lib '.';
use lib './lib';

use FunctionalParsers :set;
use Test;

# Parsers
# Digit parsers
my &p1 = apply( {1}, symbol('one'));
my &p4 = apply( {4}, symbol('four'));


plan *;

## 1
is
        pack(symbol('!'), &p1, symbol('?'))(<! one ?>).head.tail,
        1,
        'pack on : ! one ?';

## 2
is
        parenthesized(&p1)(<( one )>).head.tail,
        1,
        'parenthesized on : ( one )';

## 3
is
        bracketed(&p1)(<[ one ]>).head.tail,
        1,
        'bracketed on : [ one ]';

## 4
is
        curly-bracketed(&p1 (&) &p4)(<{ one four }>).head.tail,
        (1, 4),
        'bracketed on : { one four }';

## 5
is
        curly-bracketed(&p1 (&) &p4)(<{ one four } three>).head,
        ('three', (1, 4)),
        'bracketed on : { one four } three';

done-testing;
