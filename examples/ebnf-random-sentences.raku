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

#========================================================================================================================
say '=' x 120;

my $tstart = now;
my $res = parse-ebnf($ebnfCode, target=>'Raku::AST', style => 'Simpler').head.tail;
my $tend = now;

say $res;
say "Time to parse simple: {$tend - $tstart}";

#========================================================================================================================
say '=' x 120;

my $ebnfCodeSplit = FunctionalParsers::EBNF::Parser::Styled.normalize-rule-separation($ebnfCode);
note "\$ebnfCodeSplit :\n $ebnfCodeSplit";

$tstart = now;
my $res2 = parse-ebnf($ebnfCodeSplit, target=>'Raku::AST', style => 'Simpler').head.tail;
$tend = now;

say $res2;
say "Time to parse custom split: {$tend - $tstart}";

#========================================================================================================================
say '=' x 120;

say 'Show generated grammar:';
say parse-ebnf($ebnfCode, <CODE>, target=>'Raku::Grammar', style => 'Simpler').head.tail;

#========================================================================================================================
say '=' x 120;

say 'Show generated class for random sentence generation:';
say random-sentence($ebnfCode, 12, :!eval):restrict-recursion;

#------------------------------------------------------------------------------------------------------------------------
say '-' x 120;
my $ebnfCodeNormal = parse-ebnf($ebnfCodeSplit, <CODE>, target=>'EBNF::Standard', style => 'Simpler').head.tail;

note "\$ebnfCodeNormal : $ebnfCodeNormal";

$tstart = now;
my $res3 = parse-ebnf($ebnfCodeNormal , target=>'Raku::AST', style => 'Standard').head.tail;
$tend = now;

say $res3;
say "Time to parse custom normalized: {$tend - $tstart}";

#========================================================================================================================
say "=" x 120;

say "Generated senteces:\n";
.say for random-sentence($ebnfCodeNormal, 12, min-repetitions => 1, :eval, :restrict-recursion).pairs;


