use v6.d;

use lib '.';
use lib './lib';

use FunctionalParsers::EBNF;
use Test;

plan *;

##===========================================================
## 1
##===========================================================
my $ebnfCode1 = "
<top> = 'a' , 'b' , 'c' ;
";

## 1
is-deeply random-sentence($ebnfCode1), ("a b c",), 'Comma separated';

##===========================================================
## 2
##===========================================================
my $ebnfCode2 = "
<top> = 'a' <& 'b' <& 'c' ;
";

## 2
is-deeply random-sentence($ebnfCode2), ("a b c",), 'Left pick separated';


##===========================================================
## 3
##===========================================================
my $ebnfCode3 = "
<top> = 'a' &> 'b' &> 'c' ;
";

is-deeply random-sentence($ebnfCode3), ("a b c",), 'Right pick separated';

##===========================================================
## 4
##===========================================================
my $ebnfCode4 = "
<top> = 'a' &> 'b' , 'c' ;
";

is-deeply random-sentence($ebnfCode4), ("a b c",), 'Mix pick separated, a-c';

##===========================================================
## 5
##===========================================================
my $ebnfCode5 = "
<top> = 'a' &> 'b' , 'c' <& 'd' <& 'e';
";

is-deeply random-sentence($ebnfCode5), ("a b c d e",), 'Mix pick separated, a-e';

##===========================================================
## 6
##===========================================================
my $ebnfCode6 = "
<top> = <a> , <b> , <c>;
<a> = 'a' | 'A' ;
<b> = 'b' | 'B' ;
<c> = 'c' | 'C' ;
";

is 'a B C' (elem) random-sentence($ebnfCode6, 120).List,
        True,
        'Variaties, a-c, A-C';


done-testing;
