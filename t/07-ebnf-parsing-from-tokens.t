use v6.d;

use lib '.';
use lib './lib';

use FunctionalParsers::EBNF;
use Test;

sub local-fp-ebnf-parse($x) {
        return fp-ebnf-parse($x, :tokenized, actions => 'Raku::AST');
}

plan *;

##===========================================================
## 1 - 7
##===========================================================
my $ebnfCode1 = "
<top> = 'a' | 'b' ;
";

my @tokens1 = $ebnfCode1.split(/ \s /, :skip-empty);

## 1
isa-ok local-fp-ebnf-parse(@tokens1), List, 'Parsing produces a list';

## 2
is local-fp-ebnf-parse(@tokens1).all ~~ List, True, 'Parsing produces a list of lists';

## 3
is local-fp-ebnf-parse(@tokens1).head.head, (), 'Empty non-parsed';

## 4
isa-ok local-fp-ebnf-parse(@tokens1).head.tail, Pair;

## 5
is local-fp-ebnf-parse(@tokens1).head.tail.key, "EBNF", 'Key of the result is "EBNF"';

## 6
is-deeply
        local-fp-ebnf-parse(@tokens1).head.tail.value>>.key,
        ("EBNFRule",),
        'Value of the result is list of pairs with keys "EBNFRule"';

## 7
is-deeply
        local-fp-ebnf-parse(@tokens1).head.tail.value.Hash,
        {:EBNFRule("<top>" => :EBNFAlternatives((:EBNFTerminal("\"a\""), :EBNFTerminal("\"b\""))))},
        'Expected pairs';

##===========================================================
## 8 - 10
##===========================================================
my $ebnfCode8 = q:to/END/;
<b> = 'b' , [ '1' | '2' ] ;
END

my @tokens8 = $ebnfCode8.split(/ \s /, :skip-empty);

## 8
isa-ok local-fp-ebnf-parse(@tokens8), List, 'Parsing produces a list (b opt)';

## 9
is local-fp-ebnf-parse(@tokens8).all ~~ List, True, 'Parsing produces a list of lists (b opt)';

## 10
is-deeply
        local-fp-ebnf-parse(@tokens8).head.tail.value.Hash,
        {:EBNFRule("<b>" => :EBNFSequence((:EBNFTerminal("\"b\""), :EBNFOption(:EBNFAlternatives((:EBNFTerminal("\"1\""), :EBNFTerminal("\"2\"")))))))},
        'Expected pairs (b opt)';

##===========================================================
## 11 - 14
##===========================================================
my $ebnfCode11 = q:to/END/;
<digit> = '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' ;
<number> = <digit> , { <digit> } ;
<top> = <number> ;
END

my @tokens11 = $ebnfCode11.split(/ \s /, :skip-empty);

## 11
isa-ok local-fp-ebnf-parse(@tokens11), List, 'Parsing produces a list (number)';

## 12
is local-fp-ebnf-parse(@tokens11).all ~~ List, True, 'Parsing produces a list of lists (number)';

## 13
is-deeply
        local-fp-ebnf-parse(@tokens11).head.tail.value>>.key,
        <EBNFRule EBNFRule EBNFRule>,
        'Value of the result is list of pairs with keys "EBNFRule" (number)';

## 14
is-deeply
        local-fp-ebnf-parse(@tokens11).head.tail.value>>.value>>.key,
        ("<digit>", "<number>", "<top>"),
        'Expected rule names (number)';

##===========================================================
## 15 - 16
##===========================================================
my $ebnfCode15 = q:to/END/;
<top> = 'a' <& 'b' <& 'c' <& 'd' | <right> ;
<right> = 'e' &> 'f' &> 'g' &> 'h' ;
END

my @tokens15 = $ebnfCode15.split(/ \s /, :skip-empty);

## 15
isa-ok local-fp-ebnf-parse(@tokens15), List, 'Parsing produces a list (<& &>)';

## 16
is local-fp-ebnf-parse(@tokens15).all ~~ List, True, 'Parsing produces a list of lists (<& &>)';

## 17
is-deeply
        local-fp-ebnf-parse(@tokens15).head.tail.value>>.key,
        <EBNFRule EBNFRule>,
        'Value of the result is list of pairs with keys "EBNFRule" (<& &>)';

## 18
is-deeply
        local-fp-ebnf-parse(@tokens15).head.tail.value>>.value>>.key,
        ("<top>", "<right>"),
        'Expected rule names (<& &>)';

## 19
is-deeply
        [local-fp-ebnf-parse(@tokens15).head.tail.value.head,],
        $[:EBNFRule("<top>" => :EBNFAlternatives((:EBNFSequencePickLeft((:EBNFTerminal("\"a\""), :EBNFSequencePickLeft((:EBNFTerminal("\"b\""), :EBNFSequencePickLeft((:EBNFTerminal("\"c\""), :EBNFTerminal("\"d\""))))))), :EBNFNonTerminal("<right>"))))],
        'Expected rule structure, <top> (<& &>)';

## 20
is-deeply
        [local-fp-ebnf-parse(@tokens15).head.tail.value[1],],
        $[:EBNFRule("<right>" => :EBNFSequencePickRight((:EBNFTerminal("\"e\""), :EBNFSequencePickRight((:EBNFTerminal("\"f\""), :EBNFSequencePickRight((:EBNFTerminal("\"g\""), :EBNFTerminal("\"h\""))))))))],
        'Expected rule structure, <right> (<& &>)';

##===========================================================
## 21 - 25
##===========================================================
## Equivalences
##-----------------------------------------------------------
my $ebnfCode21 = q:to/END/;
<top> = 'a' <& 'b' <& 'c' <& 'd' | <right> ;
<right> = 'e' &> 'f' &> 'g' &> 'h' ;
END

my @tokens21 = $ebnfCode21.comb;

## 21
is-deeply
        fp-ebnf-parse(@tokens21, actions => 'Raku::AST').head.tail,
        local-fp-ebnf-parse($ebnfCode21.subst(/\s/, '')).head.tail,
        'Equivalence: tokens vs string (<& &>)';

## 22
is-deeply
        fp-ebnf-parse($ebnfCode21, actions => 'Raku::AST').head.tail,
        local-fp-ebnf-parse($ebnfCode21.subst(/\s/, '')).head.tail,
        'Equivalence: string vs string without a whitespace (<& &>)';

## 23
is-deeply
        fp-ebnf-parse($ebnfCode21, actions => 'Raku::AST').head.tail,
        local-fp-ebnf-parse($ebnfCode21.subst(/\s/, ''):g).head.tail,
        'Equivalence: string vs string without whitespaces (<& &>)';

## 24
is-deeply
        fp-ebnf-parse($ebnfCode11, actions => 'Raku::AST').head.tail,
        local-fp-ebnf-parse($ebnfCode11.subst(/\s/, ''):g).head.tail,
        'Equivalence: string vs string without whitespaces (digit)';

## 25
is-deeply
        fp-ebnf-parse($ebnfCode11, actions => 'Raku::AST').head.tail,
        local-fp-ebnf-parse($ebnfCode11.subst(/\s/, "\n"):g).head.tail,
        'Equivalence: string vs string with additional whitespaces (digit)';

##===========================================================
## 26
##===========================================================
my $ebnfCode24 = q:to/END/;
<top> = 'a' , 'b' , 'c' , 'd' ;
END

my @tokens24 = $ebnfCode24.split(/ \s+ /, :skip-empty);

## 26
is-deeply
        [local-fp-ebnf-parse(@tokens24).head.tail.value.head,],
        $[:EBNFRule("<top>" => :EBNFSequence((:EBNFTerminal("\"a\""), :EBNFTerminal("\"b\""), :EBNFTerminal("\"c\""), :EBNFTerminal("\"d\""))))],
        'Expected rule structure, <top> (,)';


done-testing;
