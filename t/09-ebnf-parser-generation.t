use v6.d;

use lib '.';
use lib './lib';

use FunctionalParsers::EBNF;
use Test;


plan *;

##===========================================================
## 1 - 4
##===========================================================
my $ebnfCode1 = q:to/END/;
<digit> = '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' ;
<number> = <digit> , { <digit> } <@ &{ $_.flat.join.Int.sqrt } ;
<top> = <number> ;
END

## 1
ok { parse-ebnf($ebnfCode1, actions => 'class', name => Whatever):eval };

## 2
my $pObj2 = parse-ebnf($ebnfCode1, actions => 'class'):eval;

my $p2 = $pObj2.new;
ok $p2.parser.('3432'.comb);

## 3
is $p2.parser.('3432'.comb).head.tail, sqrt(3432);

## 4
is $p2.parser.('893'.comb).head.tail, sqrt(893);

##===========================================================
## 5 - 6
##===========================================================
my $ebnfCode5 = q:to/END/;
<top> = 'a' <& 'b' <& 'c' <& 'd' | <right> ;
<right> = 'e' &> 'f' &> 'g' &> 'h' ;
END

my $pObj5 = parse-ebnf($ebnfCode5, actions => 'class', name => 'MyFP3'):eval;
my $p5 = $pObj5.new;

## 5
is $p5.parser.('abcd'.comb).head.tail, 'a';

## 6
is $p5.parser.('efgh'.comb).head.tail, 'h';


done-testing;
