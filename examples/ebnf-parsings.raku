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

my $ebnfCode = $ebnfCode7;
my @tokens = $ebnfCode.comb;

note $ebnfCode;

#========================================================================================================================
say '=' x 120;

my $res = fp-ebnf-parse($ebnfCode, <CODE EVAL>, actions => 'Raku::Grammar');

.say for |$res;

say $res<EVAL>.^method_table;

#========================================================================================================================
say '=' x 120;

$res = fp-ebnf-parse($ebnfCode, <CODE>, actions => 'Raku::Code');

say $res.raku;

#========================================================================================================================
say '=' x 120;

note fp-ebnf-parse(@tokens, <CODE>, actions => 'Raku::Class', name => 'MFP', prefix => 'p').head.tail;

my $classCode = fp-ebnf-parse(@tokens, <EVAL>, actions => 'Raku::Class', name => 'MFP', prefix => 'p');

say '-' x 120;
say '$classCode.raku              : ', $classCode.raku;
say '$classCode.WHAT              : ', $classCode.WHAT;
say '$classCode.^name             : ', $classCode.^name;
say '$classCode.new.^method_table : ', $classCode.new.^method_table;

say '-' x 120;
my $p = $classCode.new;


#say $p.pTOP.([|'882339'.comb, |<and some>] );
#say $p.pTOP([|'7882339'.comb, |<and some>] );

say 'Parsing...';
say $p.parser.([|'127882339'.comb, |<and some>] );
say $p.parser.('abcd'.comb);

#========================================================================================================================
say '=' x 120;
say 'WL';
say '-' x 120;

my $ebnfCodeWL = $ebnfCode.subst('&{ $_.flat.join }');

say fp-ebnf-parse($ebnfCodeWL, <CODE>, actions => 'WL::Grammar').head.tail;

#========================================================================================================================
say '=' x 120;
say 'Java';
say '-' x 120;

my $ebnfCodeJava = $ebnfCode.subst('&{ $_.flat.join }');

.say for fp-ebnf-parse($ebnfCodeJava, <CODE>, actions => 'Java::Code').head.tail;