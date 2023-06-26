use v6.d;

use lib '.';
use lib './lib';

use FunctionalParsers::EBNF;
use Test;

plan *;

##===========================================================
## 1 - 7
##===========================================================
my $ebnfCode1 = "
top -> 'a' | 'b'
";

my @tokens1 = $ebnfCode1.comb;

## 1
isa-ok fp-ebnf-parse(@tokens1, style => 'Simple'), List, 'Parsing produces a list';

## 2
is fp-ebnf-parse(@tokens1, style => 'Simple').all ~~ List, True, 'Parsing produces a list of lists';

## 3
is fp-ebnf-parse(@tokens1, style => 'Simple').head.head, (), 'Empty non-parsed';

## 4
isa-ok fp-ebnf-parse(@tokens1, style => 'Simple', target => 'Raku::AST').head.tail, Pair;

## 5
is fp-ebnf-parse(@tokens1, style => 'Simple', target => 'Raku::AST').head.tail.key, "EBNF", 'Key of the result is "EBNF"';

## 6
is-deeply
        fp-ebnf-parse(@tokens1, style => 'Simple', target => 'Raku::AST').head.tail.value>>.key,
        ("EBNFRule",),
        'Value of the result is list of pairs with keys "EBNFRule"';

## 7
is-deeply
        fp-ebnf-parse(@tokens1, style => 'Simple', target => 'Raku::AST').head.tail.value.Hash,
        {:EBNFRule("top" => :EBNFAlternatives((:EBNFTerminal("'a'"), :EBNFTerminal("'b'"))))},
        'Expected pairs';

##===========================================================
## 8 - 10
##===========================================================
my $ebnfCode8 = q:to/END/;
<b> ::= 'b' , [ '1' | '2' ] ;
END

my @tokens8 = $ebnfCode8.comb;

## 8
isa-ok fp-ebnf-parse(@tokens8, style => Whatever, target => 'Raku::AST'), List, 'Parsing produces a list (b opt)';

## 9
is fp-ebnf-parse(@tokens8, style => 'Whatever', target => 'Raku::AST').all ~~ List, True, 'Parsing produces a list of lists (b opt)';

## 10
is-deeply
        fp-ebnf-parse(@tokens8, style => Whatever, target => 'Raku::AST').head.tail.value.Hash,
        {:EBNFRule("<b>" => :EBNFSequence((:EBNFTerminal("'b'"), :EBNFOption(:EBNFAlternatives((:EBNFTerminal("'1'"), :EBNFTerminal("'2'")))))))},
        'Expected pairs (b opt)';

##===========================================================
## 11 - 14
##===========================================================
my $ebnfCode11 = q:to/END/;
digit -> '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9'
number -> digit  { digit }
top -> number
END

my @tokens11 = $ebnfCode11.comb;

## 11
isa-ok fp-ebnf-parse(@tokens11, style => 'Simple', target => 'Raku::AST'), List, 'Parsing produces a list (number)';

## 12
is fp-ebnf-parse(@tokens11, style => 'Simple', target => 'Raku::AST').all ~~ List, True, 'Parsing produces a list of lists (number)';

## 13
is-deeply
        fp-ebnf-parse(@tokens11, style => 'Simple', target => 'Raku::AST').head.tail.value>>.key,
        <EBNFRule EBNFRule EBNFRule>,
        'Value of the result is list of pairs with keys "EBNFRule" (number)';

## 14
is-deeply
        fp-ebnf-parse(@tokens11, style => 'Simple', target => 'Raku::AST').head.tail.value>>.value>>.key,
        ("digit", "number", "top"),
        'Expected rule names (number)';

##===========================================================
## 15 - 20
##===========================================================
my $ebnfCode15 = q:to/END/;
top ::= 'a' <& 'b' <& 'c' <& 'd' | right
right ::= 'e' &> 'f' &> 'g' &> 'h'
END

my @tokens15 = $ebnfCode15.comb;

## 15
isa-ok fp-ebnf-parse(@tokens15, style => Whatever, target => 'Raku::AST'), List, 'Parsing produces a list (<& &>)';

## 16
is fp-ebnf-parse(@tokens15, style => Whatever, target => 'Raku::AST').all ~~ List, True, 'Parsing produces a list of lists (<& &>)';

## 17
is-deeply
        fp-ebnf-parse(@tokens15, style => Whatever, target => 'Raku::AST').head.tail.value>>.key,
        <EBNFRule EBNFRule>,
        'Value of the result is list of pairs with keys "EBNFRule" (<& &>)';

## 18
is-deeply
        fp-ebnf-parse(@tokens15, style => Whatever, target => 'Raku::AST').head.tail.value>>.value>>.key,
        ("top", "right"),
        'Expected rule names (<& &>)';

## 19
is-deeply
        [fp-ebnf-parse(@tokens15, style => Whatever, target => 'Raku::AST').head.tail.value.head,],
        [:EBNFRule("top" => :EBNFAlternatives((:EBNFSequencePickLeft(($($(:EBNFTerminal("'a'"), :EBNFTerminal("'b'")), :EBNFTerminal("'c'")), :EBNFTerminal("'d'"))), :EBNFNonTerminal("right")))),],
        'Expected rule structure, <top> (<& &>)';

## 20
is-deeply
        [fp-ebnf-parse(@tokens15, style => Whatever, target => 'Raku::AST').head.tail.value[1],],
        [:EBNFRule("right" => :EBNFSequencePickRight((:EBNFTerminal("'e'"), $(:EBNFTerminal("'f'"), $(:EBNFTerminal("'g'"), :EBNFTerminal("'h'")))))),],
        'Expected rule structure, <right> (<& &>)';

done-testing;
