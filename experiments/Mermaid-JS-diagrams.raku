#!/usr/bin/env raku
use v6.d;

# use <. lib>;

use FunctionalParsers::EBNF;
use FunctionalParsers::EBNF::Actions::MermaidJS::Graph;

my $ebnf0 = q:to/END/;
<top> = 'a' &> <b> ;
<b> = 'b' | 'B' ;
END

my $ebnf1 = q:to/END/;
<top> = <a> | <b> ;
<a> = 'a' , { 'A' }, ['1'];
<b> = 'b' , 'B' | '2' ;
END

my $ebnf2 = q:to/END/;
<digit> = '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' ;
<number> ::= <digit> , { <digit> } ;
<top> = <number> ;
END

my $ebnf3 = q:to/END/;
<digit> = '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' ;
<number> ::= <digit> , { <digit> } <@ &{ $_.flat.join.Int } ;
<top> = <number> ;
END

my $ebnf4 = q:to/END/;
<top> = 'a' <& 'b' <& 'c' <& 'd' | <right> ;
<right> = 'e' &> 'f' &> 'g' &> 'h' ;
END

my $ebnf5 = "
top -> '4' | b
b -> 'b' | 'B'
";

## LLM generated
my $ebnf6 = q:to/END/;
<sentences> := <sentence> {<sentence>}

<sentence> := 'A' 'g' 'B' 'r' ['O' [<number>]] | 'A' 'g' 'C' 'L'

<number> := '2' | '3' | '4'
END

my $ebnf7 = q:to/END/;
sentences := sentence {sentence}

sentence := A g B r [O [number]] | A g C L

number := "2" | "3" | "4"
END

my $ebnf8 = q:to/END/;
sentence → A g B r O num | A g C L
num → 2 | 3 | 4
END

my $ebnf9 = q:to/END/;
Sentence → A g B r A g B r O Number A g C L
Number → 2 | 3 | 4
A → 'A'
g → 'g'
B → 'B'
r → 'r'
O → 'O'
C → 'C'
L → 'L'
END

my $ebnf10 = q:to/END/;
Sentence → A g B r A g B r O Number A g B r O Number2 A g C L

Number → 2 | 3 | 4
Number2 → 2 | 3 | 4
END

my $ebnf11 = q:to/END/;
<command> ::= cross tabulate <data frame> | find the contingency matrix of <data frame> | give the contingency matrix of <data frame>
<data frame> ::= <name> | the data frame <name>
<name> ::= '[a-zA-Z]+'
<column> ::= <name> | col <number>
<columns> ::= <column> | <column> <columns>
END

my $ebnf11n = q:to/END/;
<command> ::= cross tabulate <data-frame> | find the contingency matrix of <data frame> | give the contingency matrix of <data-frame>
<data-frame> ::= <name> | the data frame <name>
<name> ::= '_LetterString'
<column> ::= <name> | col <number>
<columns> ::= <column> | <column>, <columns>
END

my $ebnf11norm = q:to/END/;
<command> = 'cross' , 'tabulate' , <data frame> | 'find' , 'the' , 'contingency' , 'matrix' , 'of' , <data frame> | 'give' , 'the' , 'contingency' , 'matrix' , 'of' , <data frame> ;
<data frame> = <name> | 'the' , 'data' , 'frame' , <name> ;
<name> = '[a-zA-Z]+' ;
<column> = <name> | 'col' ,  <number> ;
<columns> = <column> | <column> , <columns> ;
END

#`[
my $res = fp-ebnf-parse($ebnf4, actions => 'Raku::AST').head.tail;
.raku.say for $res.value;

my $tracer = FunctionalParsers::EBNF::Actions::MermaidJS::Graph.new(dir-spec=>'TD');

say $tracer.trace($res.head);

say '=' x 120;

my $res2 = fp-ebnf-parse($ebnf3, actions => 'MermaidJS::Graph');

say $res2.head.tail;

say '=' x 120;

my $res3 = fp-ebnf-parse($ebnf4, actions => $tracer);

say $res3.head.tail;
]

say fp-ebnf-parse($ebnf11norm, style => 'Standard', actions => 'Raku::AST');

say "=" x 120;

say fp-ebnf-parse($ebnf11, style => 'Inverted', actions => 'Raku::Class');

say "=" x 120;

say fp-grammar-graph($ebnf11, lang => 'MermaidJS', style => Whatever);


say "=" x 120;

.say for fp-random-sentence($ebnf11norm, 12, style => 'Standard');
