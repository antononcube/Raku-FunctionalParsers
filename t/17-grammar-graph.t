use v6.d;

use lib '.';
use lib './lib';

use FunctionalParsers::EBNF;
use Test;

plan *;

##===========================================================
## 1-3
##===========================================================
my $ebnfCode1 = "
<top> = 'a' , 'b' , 'c' ;
";

## 1
isa-ok fp-grammar-graph($ebnfCode1), Str;

## 2
isa-ok fp-grammar-graph(fp-ebnf-parse($ebnfCode1, actions => "Raku::AST").head.tail), Str;

## 3
is so fp-grammar-graph($ebnfCode1) ~~ / ^ graph .* '-->' /, True;

##===========================================================
## 4
##===========================================================
my $ebnfCode2 = "
<top> = 'a' <& 'b' <& 'c' ;
";

is so fp-grammar-graph($ebnfCode2) ~~ / ^ graph .* '-->' /, True;

##===========================================================
## 5
##===========================================================
my $ebnfCode5 = "
<top> = 'a' &> 'b' &> 'c' ;
";

is so fp-grammar-graph($ebnfCode5) ~~ / ^ graph .* '-->' /, True;

##===========================================================
## 6
##===========================================================
my $ebnfCode6 = "
top -> '4' | b
b -> 'b' | 'B'
";

is so fp-grammar-graph($ebnfCode6, style => 'Simple') ~~ / ^ graph .* '-->' /, True;

##===========================================================
## 7
##===========================================================

is so fp-grammar-graph($ebnfCode6, style => 'Simple', lang => 'WL') ~~ / ^ 'Graph[' .* 'DirectedEdge' /, True;


done-testing;
