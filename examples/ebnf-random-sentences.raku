#!/usr/bin/env raku
use v6.d;

use lib '.';
use lib './lib';

use FunctionalParsers :ALL;
use FunctionalParsers::EBNF;

my $ebnfCode0 = q:to/END/;
<b> = 'b' , { '1' } , { 'G' } ;
<top> = 'a' | <b> ;
END

my $ebnfCode1 = q:to/END/;
<digit> = '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' ;
<number> = <digit> , { <digit> } ;
<top> = <number> ;
END

my $ebnfCode2 = q:to/END/;
<top> = <who> , <verb> , <lang> ;
<who> = 'I' | 'We' ;
<verb> = [ 'realy' ], ( 'love' | 'hate' | { '♥️' } | { '🤮' } );
<lang> = 'Julia' | 'Perl' | 'Python' | 'R' | 'WL' ;
END

my $ebnfCode3 = q:to/END/;
S -> NP VP
NP -> N | N PP
VP -> V NP | V PP
N -> 'R' | 'WL' | 'Julia'
PP -> P NP
P -> 'love' | 'hate'
V -> 'I' | 'We'
END

my $ebnfCode = $ebnfCode2;

note $ebnfCode;

say '=' x 120;

my $res = parse-ebnf($ebnfCode, target=>'Raku::AST', style => 'Standard').head.tail;

say $res;

say '=' x 120;

say parse-ebnf($ebnfCode, <CODE>, target=>'Raku::Grammar', style => 'Standard').head.tail;

say '=' x 120;

say random-sentence($ebnfCode, 12, :!eval):restrict-recursion;

say '-' x 120;

my $ebnfCodeNormal = parse-ebnf($ebnfCode, <CODE>, target=>'EBNF::Standard', style => 'Standard').head.tail;

note $ebnfCodeNormal;

.say for random-sentence($ebnfCodeNormal, 12, min-repetitions => 1, :eval):restrict-recursion;


