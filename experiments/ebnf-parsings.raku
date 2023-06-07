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
<b> = [ '1' | '2' ] ;
END

my $ebnfCode6 = q:to/END/;
<top> = <a> | <b> ;
<a> = 'a' , 'A' , 'å' ;
<b> = 'b' | '1' | '2' ;
END

my @tokens = $ebnfCode6.split( / \s /, :skip-empty);

say @tokens.raku;

say parse-ebnf(@tokens);
