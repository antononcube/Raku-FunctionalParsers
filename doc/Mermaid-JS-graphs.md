# Mermaid JS diagrams

## Introduction

This computational Markdown document is used for quick overview of the correctness (and quality)
of the Mermaid-JS diagrams.

```perl6

use FunctionalParsers::EBNF;
use FunctionalParsers::EBNF::Actions::MermaidJS::Graph;
```
```
# (Any)
```

------

## Simple examples

```perl6, result=asis, output.prompt=NONE, output.lang=mermaid
my $ebnf0 = q:to/END/;
<top> = 'a' &> <b> ;
<b> = 'b' | 'B' ;
END

fp-ebnf-parse($ebnf0, actions => 'MermaidJS::Graph', dir-spec => 'LR').head.tail;
```
```mermaid
graph LR
	NT:b["b"]
	T:B("B")
	seqR1(("and»"))
	NT:top["top"]
	T:b("b")
	alt5((or))
	T:a("a")
	seqR1 --> |R|NT:b
	seqR1 -.-> |L|T:a
	NT:top --> seqR1
	alt5 --> T:b
	alt5 --> T:B
	NT:b --> alt5
```


```perl6, result=asis, output.prompt=NONE, output.lang=mermaid
my $ebnf1 = q:to/END/;
<top> = <a> | <b> ;
<a> = 'a' , { 'A' }, ['1'];
<b> = 'b' , 'B' | '2' ;
END

fp-ebnf-parse($ebnf1, actions => 'MermaidJS::Graph', dir-spec => 'LR').head.tail;
```
```mermaid
graph LR
	seq13((and))
	T:B("B")
	NT:a["a"]
	rep7((*))
	T:1("1")
	seq5((and))
	alt12((or))
	T:b("b")
	opt9((?))
	T:2("2")
	NT:top["top"]
	T:a("a")
	T:A("A")
	alt1((or))
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
	seq13 --> |1|T:b
	seq13 --> |2|T:B
	alt12 --> seq13
	alt12 --> T:2
	NT:b --> alt12
```

```perl6, result=asis, output.prompt=NONE, output.lang=mermaid
my $ebnf2 = q:to/END/;
<digit> = '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' ;
<number> ::= <digit> , { <digit> } ;
<top> = <number> ;
END

fp-ebnf-parse($ebnf2, actions => 'MermaidJS::Graph', dir-spec => 'LR').head.tail;
```
```mermaid
graph LR
	seq13((and))
	T:6("6")
	T:5("5")
	T:4("4")
	T:9("9")
	T:0("0")
	T:3("3")
	NT:digit["digit"]
	T:8("8")
	alt1((or))
	T:7("7")
	NT:top["top"]
	T:2("2")
	T:1("1")
	NT:number["number"]
	rep15((*))
	alt1 --> T:0
	alt1 --> T:1
	alt1 --> T:2
	alt1 --> T:3
	alt1 --> T:4
	alt1 --> T:5
	alt1 --> T:6
	alt1 --> T:7
	alt1 --> T:8
	alt1 --> T:9
	NT:digit --> alt1
	rep15 --> NT:digit
	seq13 --> |1|NT:digit
	seq13 --> |2|rep15
	NT:number --> seq13
	NT:top --> NT:number
```

```perl6, result=asis, output.prompt=NONE, output.lang=mermaid
my $ebnf3 = q:to/END/;
<digit> = '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' ;
<number> ::= <digit> , { <digit> } <@ &{ $_.flat.join.Int } ;
<top> = <number> ;
END

fp-ebnf-parse($ebnf3, actions => 'MermaidJS::Graph', dir-spec => 'LR').head.tail;
```
```mermaid
graph LR
	T:9("9")
	T:8("8")
	alt1((or))
	rep16((*))
	T:0("0")
	NT:number["number"]
	T:1("1")
	seq14((and))
	NT:top["top"]
	NT:digit["digit"]
	apply13(("@"))
	T:2("2")
	T:4("4")
	T:5("5")
	T:3("3")
	T:7("7")
	T:6("6")
	alt1 --> T:0
	alt1 --> T:1
	alt1 --> T:2
	alt1 --> T:3
	alt1 --> T:4
	alt1 --> T:5
	alt1 --> T:6
	alt1 --> T:7
	alt1 --> T:8
	alt1 --> T:9
	NT:digit --> alt1
	rep16 --> NT:digit
	seq14 --> |1|NT:digit
	seq14 --> |2|rep16
	apply13 --> apply13FUNC[["{ $_.flat.join.Int }"]]
	apply13 --> seq14
	NT:number --> apply13
	NT:top --> NT:number
```

```perl6, result=asis, output.prompt=NONE, output.lang=mermaid
my $ebnf4 = q:to/END/;
<top> = 'a' <& 'b' <& 'c' <& 'd' | <right> ;
<right> = 'e' &> 'f' &> 'g' &> 'h' ;
END

fp-ebnf-parse($ebnf4, actions => 'MermaidJS::Graph', dir-spec => 'LR').head.tail;
```
```mermaid
graph LR
	seqR11(("and»"))
	T:a("a")
	T:e("e")
	T:d("d")
	T:f("f")
	seqL2(("«and"))
	seqL6(("«and"))
	seqL4(("«and"))
	seqR12(("and»"))
	T:g("g")
	NT:right["right"]
	NT:top["top"]
	T:b("b")
	T:c("c")
	T:h("h")
	alt1((or))
	seqR13(("and»"))
	seqL6 --> |L|T:c
	seqL6 -.-> |R|T:d
	seqL4 --> |L|T:b
	seqL4 -.-> |R|seqL6
	seqL2 --> |L|T:a
	seqL2 -.-> |R|seqL4
	alt1 --> seqL2
	alt1 --> NT:right
	NT:top --> alt1
	seqR13 --> |R|T:h
	seqR13 -.-> |L|T:g
	seqR12 --> |R|seqR13
	seqR12 -.-> |L|T:f
	seqR11 --> |R|seqR12
	seqR11 -.-> |L|T:e
	NT:right --> seqR11
```


```perl6, result=asis, output.prompt=NONE, output.lang=mermaid
my $ebnf5 = q:to/END/;
<top> = 'a' , 'b' , 'c' <& 'd' | <right> ;
<right> = 'e' , 'f' , 'g' , 'h' ;
END

fp-ebnf-parse($ebnf5, actions => 'MermaidJS::Graph', dir-spec => 'LR').head.tail;
```
```mermaid
graph LR
	seqL6(("«and"))
	NT:top["top"]
	T:d("d")
	T:f("f")
	T:a("a")
	alt1((or))
	T:c("c")
	NT:right["right"]
	seq4((and))
	T:h("h")
	T:b("b")
	T:e("e")
	seq2((and))
	seq11((and))
	T:g("g")
	seqL6 --> |L|T:c
	seqL6 -.-> |R|T:d
	seq4 --> |1|T:b
	seq4 --> |2|seqL6
	seq2 --> |1|T:a
	seq2 --> |2|seq4
	alt1 --> seq2
	alt1 --> NT:right
	NT:top --> alt1
	seq11 --> |1|T:e
	seq11 --> |2|T:f
	seq11 --> |3|T:g
	seq11 --> |4|T:h
	NT:right --> seq11
```