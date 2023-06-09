#!/usr/bin/env raku
use v6.d;

use lib '.';
use lib './lib';

use FunctionalParsers :ALL;

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

my @tokens = $ebnfCode7.split(/ \s /, :skip-empty);

say @tokens.raku;

#say $ebnfCode5.split(/ \s | <wb> /, :skip-empty);

say '=' x 120;

say parse-ebnf(@tokens);

say '=' x 120;

my @parserCode = parse-ebnf(@tokens, actions => 'generators').head.tail;

note @parserCode.join("\n");

use MONKEY-SEE-NO-EVAL;

my &pTOP;
EVAL @parserCode.subst("my &pTOP", "&pTOP");

say '1'.words.List.raku;

#my &pDIGIT = alternatives(symbol('0'), symbol('1'), symbol('2'), symbol('3'), symbol('4'), symbol('5'), symbol('6'), symbol('7'), symbol('8'), symbol('9'));
#my &pNUMBER = apply({$_.join}, greedy(&pDIGIT));
#my &pTOP = &pNUMBER;

say &pTOP('14324'.comb.List);


