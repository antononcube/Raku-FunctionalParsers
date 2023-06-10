use v6.d;

use lib '.';
use lib './lib';

use FunctionalParsers :ALL;
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
        chain-left(alternatives(@pDigits), &f)('two ⨂ four ⨂ three'.words).head.tail,
        'f(f(2,4),3)',
        'chain-left on : two ⨂ four ⨂ three';

## 2
is
        chain-right(alternatives(@pDigits), &f)('two ⨂ four ⨂ three'.words).head.tail,
        'f(2,f(4,3))',
        'chain-left on : two ⨂ four ⨂ three';

## 3
is
        chain-left(alternatives(@pDigits), &plus)('one + two + four'.words).head.tail,
        7,
        'chain-left on : one + two + four';

## 4
is
        chain-right(alternatives(@pDigits), &power)('two ** four ** three'.words).head.tail,
        2**4**3,
        'chain-right on : two ** four ** three';

## 5
my &commaForm =     {Pair.new(',', @_)}
my &pickLeftForm =  {Pair.new('<<',@_)}
my &pickRightForm = {Pair.new('>>',@_)}

my &seqSep =
        alternatives(
        apply({&commaForm},     symbol(',')),
        apply({&pickRightForm}, symbol('>>')),
        apply({&pickLeftForm},  symbol('<<')));

is
        chain-right(alternatives(@pDigits), &seqSep)('two , four << three'.words).head.tail.raku,
        '"," => [2, "<<" => [4, 3]]',
        'chain-right on : two , four <& three';

done-testing;
