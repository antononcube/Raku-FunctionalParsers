# FunctionalParsers Raku package

Raku package with a system of functional parsers.

------

## Installation

From [Zef ecosystem](https://raku.land):

```
zef install FunctionalParsers;
```

From GitHub:

```
zef install https://github.com/antononcube/Raku-FunctionalParsers.git
```

------

## Examples

Make a parser for a family of (two) simple sentences:

```perl6
use FunctionalParsers :ALL;

my &p1 = (symbol('numerical') «|» symbol('symbolic')) «&» symbol('integration');
```
```
# -> @x { #`(Block|5497413017560) ... }
```

Here we parse sentences adhering to the grammar of the defined parser:

```perl6
.say for ("numerical integration", "symbolic integration")>>.words.map({ $_ => &p1($_)});
```
```
# (numerical integration) => ((() (numerical integration)))
# (symbolic integration) => ((() (symbolic integration)))
```

These sentences are not be parsed:

```perl6
("numeric integration", "symbolic summation")>>.words.map({ $_ => &p1($_)});
```
```
# ((numeric integration) => () (symbolic summation) => ())
```

------

## Infix operators

Several notation alternatives are considered for the infix operations corresponding to
the different combinators and transformers. Here is a table with different notation styles:

| Description              | set  | double | n-ary |
|--------------------------|------|--------|-----|
| sequential combination   | (&)  | «&»    | ⨂   |
| left sequential pick     | (<&) | «&     | ◁   |
| right sequential pick    | (&>) | &»     | ▷   |
| alternatives combination | (⎸)  | «⎸»    | ⨁   |
| function application     | (^)  | «o     | ⨀   |

Consider the parsers:

```perl6
my &p1 = apply( {1}, symbol('one'));
my &p2 = apply( {2}, symbol('two'));
my &p3 = apply( {3}, symbol('three'));
my &p4 = apply( {4}, symbol('four'));
my &pM = symbol('million');
my &pTh = symbol('things');
```
```
# -> @x { #`(Block|5497413151560) ... }
```

Here are spec examples for each style of infix operators:

```perl6
# set
my &p = (&p1 (|) &p2 (|) &p3 (|) &p4) (&) (&pM (^) {10**6}) (&) &pTh;
&p('three million things'.words.List).head.tail;
```
```
# (3 (1000000 things))
```

```
# double 
(&p1 «|» &p2 «|» &p3 «|» &p4) «&» &pM «o {10**6} «&» &pTh;
```

```
# n-ary
(&p1 ⨁ &p2 ⨁ &p3 ⨁ &p4) ⨂ {10**6} ⨀ &pM ⨂ &pTh
```

**Remark:** The arguments of the apply operator `⨀` are "reversed" when compared to the arguments of the operators `(^)` and `«0`. 
For `⨀` the function to be applied is the first argument. 

------

## Parser generation

Here is an [Extended Backus-Naur Form (EBNF)](https://en.wikipedia.org/wiki/Extended_Backus–Naur_form) grammar:

```perl6
my $ebnfCode = q:to/END/;
<digit> = '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' ;
<number> = <digit> , { <digit> } ;
<top> = <number> ;
END
```
```
# <digit> = '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' ;
# <number> = <digit> , { <digit> } ;
# <top> = <number> ;
```

Here generation is the corresponding functional parsers code:

```perl6
use FunctionalParsers::EBNF;
.say for parse-ebnf($ebnfCode, target => 'Raku::Code').head.tail;
```
```
# my &pDIGIT = alternatives(symbol('0'), symbol('1'), symbol('2'), symbol('3'), symbol('4'), symbol('5'), symbol('6'), symbol('7'), symbol('8'), symbol('9'));
# my &pNUMBER = sequence(&pDIGIT, many(&pDIGIT));
# my &pTOP = &pNUMBER;
```

For more detailed examples see ["Parser-code-generation.md"](./doc/Parser-code-generation.md).

------

## Random sentence generation

Here is an EBNF grammar:

```perl6
my $ebnfCode = q:to/END/;
<top> = <who> , <verb> , <lang> ;
<who> = 'I' | 'We' ;
<verb> = 'love' | 'hate' | { '♥️' } | '🤮';
<lang> = 'Julia' | 'Perl' | 'Python' | 'R' | 'WL' ; 
END
```
```
# <top> = <who> , <verb> , <lang> ;
# <who> = 'I' | 'We' ;
# <verb> = 'love' | 'hate' | { '♥️' } | '🤮';
# <lang> = 'Julia' | 'Perl' | 'Python' | 'R' | 'WL' ;
```

Here is generation of random sentences with the grammar above:

```perl6
.say for random-sentence($ebnfCode, 12);
```
```
# I love R
# I hate Julia
# We love Perl
# We love R
# I 🤮 Julia
# I hate Julia
# I 🤮 Julia
# We hate R
# We 🤮 Perl
# I love Python
# I hate R
# We ♥️ ♥️ WL
```

------

## CLI

The package provides a Command Line Interface (CLI) script for parsing EBNF. Here is its usage message:

```shell
fp-parse-ebnf --help
```
```
# Usage:
#   fp-parse-ebnf <x> [--target[=Any]] [--name|--parser-name=<Str>] [--prefix|--rule-name-prefix=<Str>] [--modifier|--rule-name-modifier=<Str>] -- Generates random sentences for a given grammar.
#   
#     <x>                                      EBNF text.
#     --target[=Any]                           Target. [default: 'Raku::Class']
#     --name|--parser-name=<Str>               Parser name. [default: 'MyParser']
#     --prefix|--rule-name-prefix=<Str>        Rule names prefix. [default: 'p']
#     --modifier|--rule-name-modifier=<Str>    Rule names modifier. [default: 'WhateverCode']
```

------

## References

### Articles

[JF1] Jeroen Fokker,
["Function Parsers"](https://www.researchgate.net/publication/2426266_Functional_Parsers), 
(1997),
Conference: Advanced Functional Programming, 
First International Spring School on Advanced Functional Programming Techniques-Tutorial Text.
10.1007/3-540-59451-5_1.

[WV1] Wim Vanderbauwhede,
[List-based parser combinators in Haskell and Raku](https://limited.systems/articles/list-based-parser-combinators/),
(2020),
[Musings of an Accidental Computing Scientist at codeberg.page](https://wimvanderbauwhede.codeberg.page).

### Packages, repositories

[AAp1] Anton Antonov,
["FunctionalParsers.m"](https://github.com/antononcube/MathematicaForPrediction/blob/master/FunctionalParsers.m),
(2014),
[MathematicaForPrediction at GitHub](https://github.com/antononcube/MathematicaForPrediction).

[WV1] Wim Vanderbauwhede,
[List-based parser combinator library in Raku](https://github.com/wimvanderbauwhede/list-based-combinators-raku),
(2020),
[GitHub/wimvanderbauwhede](https://github.com/wimvanderbauwhede).

[WV2] Wim Vanderbauwhede,
[Parser::Combinators Perl package](https://github.com/wimvanderbauwhede/Perl-Parser-Combinators),
(2013-2015),
[GitHub/wimvanderbauwhede](https://github.com/wimvanderbauwhede).