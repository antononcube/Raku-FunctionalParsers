use v6.d;

use lib '.';
use lib './lib';

use FunctionalParsers :extra;
use Test;


plan *;

## 1
is &pInteger('3229'.comb).head.tail, 3229, 'integer 3229';

## 2
is &pNumber('232.89'.comb).head.tail, 232.89, 'number 232.89';

## 3
is &pWord('ere232_89'.comb).head.tail, 'ere232_89', 'word ere232_89';

## 4
is &pLetterWord('PereRT'.comb).head.tail, 'PereRT', 'letter word PereRT';

## 5
is &pLetterWord('PereRT93'.comb).head.tail, 'PereRT', 'letter word PereRT93';

## 6
note &pLetterWord('8PereRT'.comb);
is &pLetterWord('8PereRT'.comb), '', 'letter word 8PereRT';

## 7
is &pIdentifier('_8PereRT='.comb).head.tail, '_8PereRT', 'identifier _8PereRT';

done-testing;
