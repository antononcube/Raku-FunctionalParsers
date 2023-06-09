#!/usr/bin/env raku
use v6.d;

use lib '.';
use lib './lib';

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

say fp-ebnf-parse($ebnf5, style => 'Simple', actions => 'Raku::AST');
say fp-grammar-graph($ebnf5, lang => 'MermaidJS', style => 'Simple');
