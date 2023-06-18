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
<verb> = [ 'realy'], ( 'love' | 'hate' | { '♥️' } | { '🤮' } );
<lang> = 'Julia' | 'Perl' | 'Python' | 'R' | 'WL' ;
END

my $ebnfCode = $ebnfCode2;

note $ebnfCode;

say '=' x 120;

my $res = parse-ebnf($ebnfCode, target=>'Raku::Pairs').head.tail;

say $res;

say '=' x 120;

say parse-ebnf($ebnfCode, <CODE>, target=>'Raku::Class').head.tail;

say '=' x 120;

say random-sentences($ebnfCode, 12, :!eval);

say '-' x 120;

.say for random-sentences($ebnfCode, 12, min-repetitions => 1, :eval);


