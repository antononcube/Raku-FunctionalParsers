# Parser code generation

## Introduction

This document has examples of parser code generation for different programming languages. 

## Raku class code

### FunctionalParsers

In this section we generate Raku parser code that uses the functions of this package, "FunctionalParsers". 

```perl6
use FunctionalParsers;
use FunctionalParsers::EBNF;

my $ebnfCode = q:to/END/;
<digit> = '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' ;
<number> = <digit> , { <digit> } <@ &{ $_.flat.join } ;
<top> = <number> ;
END

my $res = fp-ebnf-parse($ebnfCode, <CODE>, target => 'Raku::Class');
$res.head.tail;
```
```
# class FP {
# 	method pDIGIT(@x) { alternatives(symbol('0'), symbol('1'), symbol('2'), symbol('3'), symbol('4'), symbol('5'), symbol('6'), symbol('7'), symbol('8'), symbol('9'))(@x) }
# 	method pNUMBER(@x) { apply(&{ $_.flat.join }, sequence({self.pDIGIT($_)}, many({self.pDIGIT($_)})))(@x) }
# 	method pTOP(@x) { {self.pNUMBER($_)}(@x) }
# 	has &.parser is rw = -> @x { self.pTOP(@x) };
# }
````

Let us get (evaluated) class of the code above:

```perl6
my $class = fp-ebnf-parse($ebnfCode, <EVAL>, target => 'Raku::Class', parser-name => 'MyFP');
```
```
# (MyFP)
```

Here we create an instance of the obtained class and parse with it:

```perl6
$class.new.parser.('3234'.comb);
```
```
# ((() 3234) ((4) 323) ((3 4) 32) ((2 3 4) 3))
```

Here we generate the parser class code again, but here we place it into an "as-is" Markdown cell:

```perl6, result=asis, output-prompt=NONE, output-lang=perl6
fp-ebnf-parse($ebnfCode, <CODE>, target => 'Raku::Class').head.tail;
```
```perl6
class FP {
	method pDIGIT(@x) { alternatives(symbol('0'), symbol('1'), symbol('2'), symbol('3'), symbol('4'), symbol('5'), symbol('6'), symbol('7'), symbol('8'), symbol('9'))(@x) }
	method pNUMBER(@x) { apply(&{ $_.flat.join }, sequence({self.pDIGIT($_)}, many({self.pDIGIT($_)})))(@x) }
	method pTOP(@x) { {self.pNUMBER($_)}(@x) }
	has &.parser is rw = -> @x { self.pTOP(@x) };
}
```

### Code

In this sub-section we generate code that has "stand-alone" parser functions.

Here we generate code of the parsers and place it into an "as-is" Markdown cell:

```perl6, result=asis, output-prompt=NONE, output-lang=perl6
.say for fp-ebnf-parse($ebnfCode, <CODE>, target => 'Raku::Code', parser-name => 'MyFP').head.tail;
```
```perl6
my &pDIGIT = alternatives(symbol('0'), symbol('1'), symbol('2'), symbol('3'), symbol('4'), symbol('5'), symbol('6'), symbol('7'), symbol('8'), symbol('9'));
my &pNUMBER = apply(&{ $_.flat.join }, sequence(&pDIGIT, many(&pDIGIT)));
my &pTOP = &pNUMBER;
```


### Grammar

In this sub-section we generate code for Raku's built-in grammars.

Here we generate grammar class and place it into an "as-is" Markdown cell:

```perl6, result=asis, output-prompt=NONE, output-lang=perl6
fp-ebnf-parse($ebnfCode, <CODE>, target => 'Raku::Grammar', parser-name => 'MyFP').head.tail;
```
```perl6
grammar MyFP {
	rule pDIGIT { '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' }
	rule pNUMBER { <pDIGIT> <pDIGIT>* }
	rule TOP { <pNUMBER> }
}
```

Here we generate the grammar code and evaluate it:

```perl6
my $gr = fp-ebnf-parse($ebnfCode, <EVAL>, target => 'Raku::Grammar', parser-name => 'MyGr');
```
```
# (MyGr)
```

Here we parse with the grammar:

```perl6
$gr.parse('944'.comb);
```
```
# ｢9 4 4｣
#  pNUMBER => ｢9 4 4｣
#   pDIGIT => ｢9 ｣
#   pDIGIT => ｢4 ｣
#   pDIGIT => ｢4｣
```

-----

## Java code

*TBD...*

-----

## Wolfram Language code

In this section we generate Wolfram Language (WL) parsers code.
(WL is also known as "Mathematica".)

### FunctionalParsers

In this sub-section generate code for the WL paclet 
["AntonAntonov/FunctionalParsers"](https://resources.wolframcloud.com/PacletRepository/resources/AntonAntonov/FunctionalParsers/)
(which corresponds to this Raku package "FunctionalParsers".) 

Here we transform the EBNF code above to have WL function:

```perl6
my $ebnfCodeWL = $ebnfCode.subst('$_.flat.join', 'StringJoin@*Flatten');
```
```
# <digit> = '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' ;
# <number> = <digit> , { <digit> } <@ &{ StringJoin@*Flatten } ;
# <top> = <number> ;
```

Here we generate WL code:

```perl6, result=asis, output-prompt=NONE, output-lang=perl6
fp-ebnf-parse($ebnfCodeWL, <CODE>, target => 'WL::Code').head.tail.subst(/';' \s* /,";\n"):g;
```
```perl6
pDIGIT = ParseAlternativeComposition[ParseSymbol["0"], ParseSymbol["1"], ParseSymbol["2"], ParseSymbol["3"], ParseSymbol["4"], ParseSymbol["5"], ParseSymbol["6"], ParseSymbol["7"], ParseSymbol["8"], ParseSymbol["9"]];
pNUMBER = ParseApply[ StringJoin@*Flatten , ParseSequentialComposition[pDIGIT, ParseMany[pDIGIT]]];
pTOP = pNUMBER;
```

### GrammarRules

In this sub-section we generate code for WL's built-in 
[`GrammarRules`](https://reference.wolfram.com/language/ref/GrammarRules.html).

```perl6
fp-ebnf-parse($ebnfCodeWL, <CODE>, target => 'WL::Grammar').head.tail;
```
```
# GrammarRules[{"pTOP" -> "pNUMBER"}, {"pDIGIT" -> "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9","pNUMBER" -> FixedOrder["pDIGIT", "pDIGIT"..] :>  StringJoin@*Flatten }]
```