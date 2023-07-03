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
	NT:a["a"]
	T:b("b")
	opt9((?))
	T:2("2")
	T:1("1")
	alt1((or))
	T:a("a")
	rep7((*))
	NT:top["top"]
	T:A("A")
	NT:b["b"]
	alt14((or))
	seq12((and))
	T:B("B")
	seq5((and))
	alt1 --> NT:a
	alt1 --> NT:b
	NT:top --> alt1
	rep7 --> T:A
	opt9 --> T:1
	seq5 --> T:a
	seq5 --> rep7
	seq5 --> opt9
	NT:a --> seq5
	alt14 --> T:B
	alt14 --> T:2
	seq12 --> T:b
	seq12 --> alt14
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
	T:B("B")
	NT:a["a"]
	rep7((*))
	T:1("1")
	T:b("b")
	NT:b["b"]
	seq5((and))
	seq13((and))
	opt9((?))
	alt1((or))
	T:a("a")
	T:2("2")
	T:A("A")
	alt12((or))
	NT:top["top"]
	alt1 --> NT:a
	alt1 --> NT:b
	NT:top --> alt1
	rep7 --> T:A
	opt9 --> T:1
	seq5 --> T:a
	seq5 --> rep7
	seq5 --> opt9
	NT:a --> seq5
	seq13 --> T:b
	seq13 --> T:B
	alt12 --> seq13
	alt12 --> T:2
	NT:b --> alt12
```
