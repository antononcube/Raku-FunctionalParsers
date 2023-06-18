# Parser code generation

## Introduction

This document has examples of parser code generation for different programming languages. 

## Raku class code

```perl6
use FunctionalParsers;
use FunctionalParsers::EBNF;

my $ebnfCode = q:to/END/;
<digit> = '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' ;
<number> = <digit> , { <digit> } <@ &{ $_.flat.join } ;
<top> = <number> ;
END

my $res = parse-ebnf($ebnfCode, <CODE>, target => 'Raku::Class');
$res.head.tail;
````

Let us get (evaluated) class of the code above:

```perl6
my $class = parse-ebnf($ebnfCode, <EVAL>, target => 'Raku::Class', parser-name => 'MyFP');
```

Here we create an instance of the obtained class and parse with it:

```perl6
$class.new.parser.('3234'.comb);
```

Here we generate the parser class code but evaluate into a "as-is" Markdown cells:

```perl6, result=asis, output-prompt=NONE, output-lang=perl6
parse-ebnf($ebnfCode, <CODE>, target => 'Raku::Class').head.tail
```

Here we evaluate with the grammar above:

```perl6
FP.pTOP('323'.comb);
```