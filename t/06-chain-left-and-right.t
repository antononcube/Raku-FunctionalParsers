use v6.d;

use lib '.';
use lib './lib';

use FunctionalParsers :set, :ALL;
use Test;

# Digit parsers
my @intNames = <zero one two three four five six seven eight nine ten>;
my @pDigits = (@intNames Z ^10).map(-> $p { apply({ $p[1] }, symbol($p[0])) });


# Shape function separator
my &fform = {"f($^a,$^b)"};
my &f = apply({&fform}, symbol('⨂'));

# Plus and power separators
my &plus = apply({&[+]}, symbol('+'));
my &power = apply({&[**]}, symbol('**'));

plan *;

## 1
is
        chain-left(&f, alternatives(@pDigits))('two ⨂ four ⨂ three'.words).head.tail,
        'f(f(2,4),3)',
        'chain-left on : two ⨂ four ⨂ three';

## 2
is
        chain-right(&f, alternatives(@pDigits))('two ⨂ four ⨂ three'.words).head.tail,
        'f(2,f(4,3))',
        'chain-left on : two ⨂ four ⨂ three';

## 3
is
        chain-left(&plus, alternatives(@pDigits))('one + two + four'.words).head.tail,
        7,
        'chain-left on : one + two + four';

## 4
is
        chain-right(&power, alternatives(@pDigits))('two ** four ** three'.words).head.tail,
        2**4**3,
        'chain-right on : two ** four ** three';

done-testing;
