#!/usr/bin/env raku
use v6.d;

use lib '.';
use lib './lib';

use FunctionalParsers :ALL;
use FunctionalParsers::EBNF;
use FunctionalParsers::EBNF::Actions::MermaidJS::Graph;

my $ebnf0 = q:to/END/;
<top> = 'a' <& 'b' , 'c' , 'd' | <right> ;
<right> = 'e' , 'f' , 'g' , 'h' ;
END

my $ebnf1 = q:to/END/;
<top> = 'a' <& 'b' <& 'c' <& 'd' | <right> ;
<right> = 'e' &> 'f' &> 'g' &> 'h' ;
END

my $res = fp-ebnf-parse($ebnf0, actions => 'Raku::AST').head.tail;

.raku.say for $res.value;

say '=' x 120;

#my &fform = {"f($^a,$^b)"};

my &fformComma = { ('Sequence', $^a, $^b) };
my &fformLeft = { ('SequencePickLeft', $^a, $^b) };
my &fformRight = { ('SequencePickRight', $^a, $^b) };

my &sep = alternatives(
        apply({ &fformComma }, sp(symbol(','))),
        apply({ &fformLeft }, sp(symbol('<&'))),
        apply({ &fformRight }, sp(symbol('&>'))));

my $res2 = just(chain-right(satisfy({ True }), &sep))('a <& b , c &> d'.words);
say $res2;

#say shortest(chain-right(satisfy({ True }), &sep))("'a' <& 'b' , 'c' , 'd' | <right> ;".words);

sub seq-rec($_) {
    if $_ ~~ Positional && $_.elems > 1 {
        Pair.new("EBNF" ~ $_[0], ($_[1], seq-rec($_[2])))
    } else {
        $_
    }
}

say seq-rec($res2.head.tail);