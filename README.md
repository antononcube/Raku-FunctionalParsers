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
use FunctionalParsers;

my &p1 = (symbol('numerical') «|» symbol('symbolic')) «&» symbol('integration');
```
```
# -> @x { #`(Block|5972409448152) ... }
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

| Description              | 1st  | 2nd | 3rd |
|--------------------------|------|----|----|
| sequential combination   | (&)  | «&» | ⨂  |
| left sequential pick     | (<&) | «& | ◀  |
| right sequential pick    | (&>) | &» | ▶  |
| alternatives combination | (⎸)  | «⎸» | ⨁  |
| function application     | (^)  | «o | ⨀  |

Here are spec examples for each style:

```
# 1st
(&p1 (|) &p2 (|) &p3 (|) &p4) (&) &pM (^) {10**6} (&) &pT

# 2nd 
(&p1 «|» &p2 «|» &p3 «|» &p4) «&» &pM «o {10**6} «&» &pT

# 3rd
(&p1 ⨁ &p2 ⨁ &p3 ⨁ &p4) ⨂ {10**6} ⨀ &pM ⨂ &pT

```

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