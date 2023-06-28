#!/usr/bin/env raku
use v6.d;

use lib '.';
use lib './lib';

use EBNF::Grammar;
use EBNF::Grammar::Standardish;
use FunctionalParsers::EBNF;
use FunctionalParsers::EBNF::Actions::MermaidJS::Graph;

my $ebnf0 = q:to/END/;
<top> = 'a' , <b> ;
<b> = 'b' | 'B' ;
END

my $ebnf1 = q:to/END/;
<top> = <a> | <b> ;
<a> = 'a' , { 'A' };
<b> = 'b' , 'B' | [ '1' ];
END

my $ebnf2 = q:to/END/;
<digit> = '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' ;
<number> ::= <digit> , { <digit> } ;
<top> = <number> ;
END

my $res = fp-ebnf-parse($ebnf1, actions => 'Raku::AST').head.tail;
.raku.say for $res.value;

my $tracer = FunctionalParsers::EBNF::Actions::MermaidJS::Graph.new(dir-spec=>'LR');

say $tracer.trace($res.head);

say '=' x 120;

my $res2 = fp-ebnf-parse($ebnf1, actions => 'MermaidJS::Graph');

say $res2.head.tail;

say '=' x 120;

my $res3 = fp-ebnf-parse($ebnf1, actions => $tracer);

say $res3.head.tail;
