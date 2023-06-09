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

my $res = fp-ebnf-parse($ebnfCode, <CODE>, actions => 'Raku::Class');
$res.head.tail;
````

Let us get (evaluated) class of the code above:

```perl6
my $class = fp-ebnf-parse($ebnfCode, <EVAL>, actions => 'Raku::Class', parser-name => 'MyFP');
```

Here we create an instance of the obtained class and parse with it:

```perl6
$class.new.parser.('3234'.comb);
```

Here we generate the parser class code again, but here we place it into an "as-is" Markdown cell:

```perl6, result=asis, output-prompt=NONE, output-lang=perl6
fp-ebnf-parse($ebnfCode, <CODE>, actions => 'Raku::Class').head.tail;
```

### Code

In this sub-section we generate code that has "stand-alone" parser functions.

Here we generate code of the parsers and place it into an "as-is" Markdown cell:

```perl6, result=asis, output-prompt=NONE, output-lang=perl6
.say for fp-ebnf-parse($ebnfCode, <CODE>, actions => 'Raku::Code', parser-name => 'MyFP').head.tail;
```


### Grammar

In this sub-section we generate code for Raku's built-in grammars.

Here we generate grammar class and place it into an "as-is" Markdown cell:

```perl6, result=asis, output-prompt=NONE, output-lang=perl6
fp-ebnf-parse($ebnfCode, <CODE>, actions => 'Raku::Grammar', parser-name => 'MyFP').head.tail;
```

Here we generate the grammar code and evaluate it:

```perl6
my $gr = fp-ebnf-parse($ebnfCode, <EVAL>, actions => 'Raku::Grammar', parser-name => 'MyGr');
```

Here we parse with the grammar:

```perl6
$gr.parse('944'.comb);
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

Here we generate WL code:

```perl6, result=asis, output-prompt=NONE, output-lang=perl6
fp-ebnf-parse($ebnfCodeWL, <CODE>, actions => 'WL::Code').head.tail.subst(/';' \s* /,";\n"):g;
```

### GrammarRules

In this sub-section we generate code for WL's built-in 
[`GrammarRules`](https://reference.wolfram.com/language/ref/GrammarRules.html).

```perl6
fp-ebnf-parse($ebnfCodeWL, <CODE>, actions => 'WL::Grammar').head.tail;
```