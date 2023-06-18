#!/usr/bin/env raku
use v6.d;

use lib '.';
use lib './lib';

use FunctionalParsers::EBNF;

my $ebnfCode0 = "
<top> = 'a' | 'b' ;
";

my $ebnfCode1 = "
<top> = <a> | <b> ;
<a> = 'a' ;
<b> = 'b' ;
";

my $ebnfCode2 = q:to/END/;
<top> = <a> | <b> ;
<a> = 'a' ;
<b> = 'b' , <c> ;
<c> = '1' | '2' ;
END

my $ebnfCode3 = q:to/END/;
<top> = <a> | <b> ;
<a> = 'a' ;
<b> = 'b' , { ',' , ( '1' | '2' ) } ;
END

my $ebnfCode4 = q:to/END/;
<b> = 'b' , [ '1' | '2' ] ;
END

my $ebnfCode5 = q:to/END/;
<top> = ( '1' | '2' ) ;
END

my $ebnfCode6 = q:to/END/;
<top> = <a> | <b> | <c> ;
<a> = 'a' , 'A' , 'å' ;
<b> = 'b' | '1' | '2' ;
<c> = 'c' , <a> , <b> ;
END

my $ebnfCode7 = q:to/END/;
<digit> = '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' ;
<number> = <digit> , { <digit> } ;
<top> = <number> ;
END

my $ebnfCode8 = q:to/END/;
<top> = '1' , '2' <@ &{sqrt($_.join.Numeric)} ;
END

my $ebnfCode9 = q:to/END/;
<top> = '7' <@ sqrt | '8' <@ {$_**2} ;
END

my $ebnfCode10 = q:to/END/;
<top> = 'a' <& 'b' <& 'c' <& 'd' | <top3> ;
<top3> = 'e' &> 'f' &> 'g' &> 'h' ;
END

my $ebnfCode = $ebnfCode8;
my @tokens = $ebnfCode.comb;

note $ebnfCode;

say '=' x 120;

my $res = parse-ebnf($ebnfCode, <CODE EVAL>, target => 'Raku::Class');

.say for |$res;

say $res<EVAL>.^method_table;

say '=' x 120;

$res = parse-ebnf($ebnfCode, <CODE>, target => 'Raku::Code');

say $res.raku;