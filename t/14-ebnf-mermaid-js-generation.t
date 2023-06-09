use v6.d;

use lib '.';
use lib './lib';

use FunctionalParsers::EBNF;
use Test;


plan *;

##===========================================================
## 1 - 2
##===========================================================
my $ebnfCode1 = q:to/END/;
<top> = <a> | <b> ;
<a> = 'a' , { 'A' }, ['1'];
<b> = 'b' , 'B' | '2' ;
END

## 1
ok { fp-ebnf-parse($ebnfCode1, <CODE>, actions => 'MermaidJS::Graph', name => Whatever) };

## 2
isa-ok fp-ebnf-parse($ebnfCode1, <CODE>, actions => 'MermaidJS::Graph').head.tail, Str;


##===========================================================
## 3 - 4
##===========================================================
my $ebnfCode3 = q:to/END/;
<digit> = '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' ;
<number> = <digit> , { <digit> } <@ &{ $_.flat.join.Int.sqrt } ;
<top> = <number> ;
END

## 3
ok { fp-ebnf-parse($ebnfCode3, <CODE>, actions => 'MermaidJS::Graph', name => Whatever) };

## 4
isa-ok fp-ebnf-parse($ebnfCode3, <CODE>, actions => 'MermaidJS::Graph').head.tail, Str;

done-testing;
