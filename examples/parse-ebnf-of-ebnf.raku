#!/usr/bin/env raku
use v6.d;

use lib '.';
use lib './lib';

use FunctionalParsers::EBNF;

my $ebnfCode = slurp( $*CWD ~ '/resources/EBNF.ebnf');
note $ebnfCode;

#========================================================================================================================
say '=' x 120;

my $res = fp-ebnf-parse($ebnfCode, <CODE>, target => 'Raku::Grammar', style => 'Simpler');

.say for $res.head.tail;
