# Graph representation of grammars

## Introduction

```perl6
use FunctionalParsers;
use FunctionalParsers::EBNF;
use EBNF::Grammar;
use Grammar::TokenProcessing;
```
```
# (Any)
```

------

## Generating Mermaid diagrams for EBNFs

The function `fp-ebnf-parse` can produce
[Mermaid-JS diagrams](https://mermaid.js.org)
corresponding to grammars with the target "MermaidJS::Graph".
Here is an example:

```perl6, result=asis, output-lang=mermaid, output-prompt=NONE
my $ebnfCode3 = q:to/END/;
<top> = <a> | <b> ;
<a> = 'a' , { 'A' } , [ '1' ];
<b> = 'b' , ( 'B' | '2' );
END

fp-ebnf-parse($ebnfCode3, target=>'MermaidJS::Graph', dir-spec => 'LR').head.tail
```
```mermaid
graph LR
	T:B("B")
	T:2("2")
	T:1("1")
	rep7((*))
	NT:top["top"]
	seq12((and))
	NT:a["a"]
	alt14((or))
	T:a("a")
	T:A("A")
	seq5((and))
	opt9((?))
	alt1((or))
	T:b("b")
	NT:b["b"]
	alt1 --> NT:a
	alt1 --> NT:b
	NT:top --> alt1
	rep7 --> T:A
	opt9 --> T:1
	seq5 --> |1|T:a
	seq5 --> |2|rep7
	seq5 --> |3|opt9
	NT:a --> seq5
	alt14 --> T:B
	alt14 --> T:2
	seq12 --> |1|T:b
	seq12 --> |2|alt14
	NT:b --> seq12
```

Here is a legend:

- The non-terminals are shown with rectangles
- The terminals are shown with round rectangles
- The "conjunctions" are shown in disks

**Remark:** The Markdown cell above has the parameters `result=asis, output-lang=mermaid, output-prompt=NONE`
which allow for direct diagram rendering of the obtained Mermaid code in various Markdown viewers (GitHub, IntelliJ, etc.)

Compare the following EBNF grammar and corresponding diagram with the ones above:

```perl6, result=asis, output-lang=mermaid, output-prompt=NONE
my $ebnfCode4 = q:to/END/;
<top> = <a> | <b> ;
<a> = 'a' , { 'A' } , [ '1' ] ;
<b> = 'b' , 'B' | '2' ;
END

fp-ebnf-parse($ebnfCode4, target=>'MermaidJS::Graph', dir-spec => 'LR').head.tail
```
```mermaid
graph LR
	rep7((*))
	T:1("1")
	NT:b["b"]
	T:a("a")
	T:B("B")
	NT:top["top"]
	seq13((and))
	T:2("2")
	alt1((or))
	opt9((?))
	alt12((or))
	NT:a["a"]
	T:A("A")
	T:b("b")
	seq5((and))
	alt1 --> NT:a
	alt1 --> NT:b
	NT:top --> alt1
	rep7 --> T:A
	opt9 --> T:1
	seq5 --> |1|T:a
	seq5 --> |2|rep7
	seq5 --> |3|opt9
	NT:a --> seq5
	seq13 --> |1|T:b
	seq13 --> |2|T:B
	alt12 --> seq13
	alt12 --> T:2
	NT:b --> alt12
```

------

## More complicated grammar

Consider this grammar:

```perl6
my $ebnfExpr = q:to/END/;
start   = expr ;
expr    = term '+' expr | term '-' expr | term ;
term    = term '*' factor | term '/' factor | factor ;
factor  = '+' factor | '-' factor | (expr) | integer | integer '.' integer ;
integer = digit integer | digit ;
digit   = '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' ;
END
```
```
# start   = expr ;
# expr    = term '+' expr | term '-' expr | term ;
# term    = term '*' factor | term '/' factor | factor ;
# factor  = '+' factor | '-' factor | (expr) | integer | integer '.' integer ;
# integer = digit integer | digit ;
# digit   = '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' ;
```

Here we produce the graph using special parsing style:

```perl6, result=asis, output.lang=mermaid, output.prompt=NONE
fp-grammar-graph($ebnfExpr, style => 'Relaxed')
```
```mermaid
graph TD
	alt3((or))
	T:1("1")
	seq4((and))
	T:9("9")
	T:2("2")
	T:*("*")
	NT:term["term"]
	T:8("8")
	NT:expr["expr"]
	T:+("+")
	seq34((and))
	alt45((or))
	alt39((or))
	T:-("-")
	T:5("5")
	T:3("3")
	NT:factor["factor"]
	seq8((and))
	seq29((and))
	alt14((or))
	T:6("6")
	T:.(".")
	NT:integer["integer"]
	NT:digit["digit"]
	seq26((and))
	T:/("/")
	alt25((or))
	seq15((and))
	T:0("0")
	seq40((and))
	T:4("4")
	seq19((and))
	NT:start["start"]
	T:7("7")
	NT:start --> NT:expr
	seq4 --> |1|NT:term
	seq4 --> |2|T:+
	seq4 --> |3|NT:expr
	seq8 --> |1|NT:term
	seq8 --> |2|T:-
	seq8 --> |3|NT:expr
	alt3 --> seq4
	alt3 --> seq8
	alt3 --> NT:term
	NT:expr --> alt3
	seq15 --> |1|NT:term
	seq15 --> |2|T:*
	seq15 --> |3|NT:factor
	seq19 --> |1|NT:term
	seq19 --> |2|T:/
	seq19 --> |3|NT:factor
	alt14 --> seq15
	alt14 --> seq19
	alt14 --> NT:factor
	NT:term --> alt14
	seq26 --> |1|T:+
	seq26 --> |2|NT:factor
	seq29 --> |1|T:-
	seq29 --> |2|NT:factor
	seq34 --> |1|NT:integer
	seq34 --> |2|T:.
	seq34 --> |3|NT:integer
	alt25 --> seq26
	alt25 --> seq29
	alt25 --> NT:expr
	alt25 --> NT:integer
	alt25 --> seq34
	NT:factor --> alt25
	seq40 --> |1|NT:digit
	seq40 --> |2|NT:integer
	alt39 --> seq40
	alt39 --> NT:digit
	NT:integer --> alt39
	alt45 --> T:0
	alt45 --> T:1
	alt45 --> T:2
	alt45 --> T:3
	alt45 --> T:4
	alt45 --> T:5
	alt45 --> T:6
	alt45 --> T:7
	alt45 --> T:8
	alt45 --> T:9
	NT:digit --> alt45
```

------

## Generating Mermaid diagrams for Raku grammars

In order to generate graphs for Raku grammars we use the following steps:

1. Translate Raku-grammar code into EBNF code
2. Translate EBNF code into graph code (Mermaid-JS or WL)

Consider a grammar for parsing integers:

```perl6
grammar LangLove {
    rule TOP  { <workflow-command> }
    rule workflow-command  { <who> 'really'? <love> <lang> }
    token who { 'I' | 'We' }
    token love { 'hate' | 'love' }
    token lang { 'Raku' | 'Perl' | 'Rust' | 'Go' | 'Python' | 'Ruby' }
}
```
```
# (LangLove)
```

Here is an example parsing:

```perl6
LangLove.parse('I hate Perl')
```
```
# ｢I hate Perl｣
#  workflow-command => ｢I hate Perl｣
#   who => ｢I｣
#   love => ｢hate｣
#   lang => ｢Perl｣
```

First we derive the corresponding EBNF grammar:

```perl6
my $ebnfLangLove = to-ebnf-grammar(LangLove)
```
```
# <TOP> = <workflow-command>  ;
# <lang> = 'Raku'  | 'Perl'  | 'Rust'  | 'Go'  | 'Python'  | 'Ruby'  ;
# <love> = 'hate'  | 'love'  ;
# <who> = 'I'  | 'We'  ;
# <workflow-command> = <who> , ['really'] , <love> , <lang>  ;
```

Here is the corresponding Mermaid-JS graph:

```perl6, result=asis, output.lang=mermaid, output.prompt=NONE
fp-grammar-graph($ebnfLangLove)
```
```mermaid
graph TD
	NT:lang["lang"]
	NT:love["love"]
	T:We("We")
	T:I("I")
	NT:TOP["TOP"]
	NT:who["who"]
	T:Ruby("Ruby")
	T:Go("Go")
	T:Perl("Perl")
	T:Raku("Raku")
	alt11((or))
	T:Python("Python")
	alt15((or))
	T:hate("hate")
	seq19((and))
	T:Rust("Rust")
	T:really("really")
	opt21((?))
	NT:workflow-command["workflow-command"]
	alt3((or))
	T:love("love")
	NT:TOP --> NT:workflow-command
	alt3 --> T:Raku
	alt3 --> T:Perl
	alt3 --> T:Rust
	alt3 --> T:Go
	alt3 --> T:Python
	alt3 --> T:Ruby
	NT:lang --> alt3
	alt11 --> T:hate
	alt11 --> T:love
	NT:love --> alt11
	alt15 --> T:I
	alt15 --> T:We
	NT:who --> alt15
	opt21 --> T:really
	seq19 --> |1|NT:who
	seq19 --> |2|opt21
	seq19 --> |3|NT:love
	seq19 --> |4|NT:lang
	NT:workflow-command --> seq19
```