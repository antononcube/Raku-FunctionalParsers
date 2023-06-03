# FunctionalParsers Raku package

Raku package with a system of functional parsers.

-----

## Installation

*TBD...*

-----

## Examples

### Basic

Make a parser for a family of (two) simple sentences:

```perl6
use FunctionalParsers :ALL;

my &p1 = (symbol('numerical') «|» symbol('symbolic')) «&» symbol('integration');
```
```
# -> @x { #`(Block|6151354843096) ... }
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

-----

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
# -> @x { #`(Block|6151355049480) ... }
```

Here are spec examples for each style of infix operators:

```perl6
# set
my &p = (&p1 (|) &p2 (|) &p3 (|) &p4) (&) (&pM (^) {10**6}) (&) &pTh;
&p('three million things'.words.List).head.tail;
```
```
# ((3 1000000) things)
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

-----

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