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
<top> = 'a' | 'b' ;
";

my @tokens1 = $ebnfCode1.comb;

## 1
isa-ok fp-ebnf-parse(@tokens1, actions => 'Raku::Code'), List, 'Parsing produces a list';

## 2
is fp-ebnf-parse(@tokens1, actions => 'Raku::Code').head.tail.all ~~ Str, True, 'Parsing produces a list of Strings';

## 3
is fp-ebnf-parse(@tokens1, actions => 'Raku::Code').head.head.trim, '', 'Empty non-parsed';

## 4
isa-ok fp-ebnf-parse(@tokens1, actions => 'Raku::AST').head.tail, Pair;

## 5
is fp-ebnf-parse(@tokens1, actions => 'Raku::AST').head.tail.key, "EBNF", 'Key of the result is "EBNF"';

## 6
is-deeply
        fp-ebnf-parse(@tokens1, actions => 'Raku::AST').head.tail.value>>.key,
        ("EBNFRule",),
        'Value of the result is list of pairs with keys "EBNFRule"';

## 7
is-deeply
        fp-ebnf-parse(@tokens1, actions => 'Raku::AST').head.tail.value.Hash,
        {:EBNFRule("<top>" => :EBNFAlternatives((:EBNFTerminal("'a'"), :EBNFTerminal("'b'"))))},
        'Expected pairs';

## 8
is-deeply
        fp-ebnf-parse($ebnfCode1, actions => 'Raku::AST').head.tail,
        fp-ebnf-parse(@tokens1, actions => 'Raku::AST').head.tail,
        'Same results for string and tokens';

##===========================================================
## 9 - 12
##===========================================================
my $ebnfCode9 = q:to/END/;
<b> = 'b' , [ '1' | '2' ] ;
END

my @tokens9 = $ebnfCode9.comb;

## 9
isa-ok fp-ebnf-parse(@tokens9, actions => 'Raku::AST'), List, 'Parsing produces a list (b opt)';

## 10
is fp-ebnf-parse(@tokens9, actions => 'Raku::AST').all ~~ List, True, 'Parsing produces a list of list (b opt)';

## 11
is-deeply
        fp-ebnf-parse(@tokens9, actions => 'Raku::AST').head.tail.value.Hash,
        {:EBNFRule("<b>" => :EBNFSequence((:EBNFTerminal("'b'"), :EBNFOption(:EBNFAlternatives((:EBNFTerminal("'1'"), :EBNFTerminal("'2'")))))))},
        'Expected pairs (b opt)';

## 12
is-deeply
        fp-ebnf-parse($ebnfCode9, actions => 'Raku::AST').head.tail,
        fp-ebnf-parse(@tokens9, actions => 'Raku::AST').head.tail,
        'Same results for string and tokens (b opt)';

##===========================================================
## 13 - 17
##===========================================================
my $ebnfCode13 = q:to/END/;
<digit> = '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' ;
<number> = <digit> , { <digit> } ;
<top> = <number> ;
END

my @tokens13 = $ebnfCode13.comb;

## 13
isa-ok fp-ebnf-parse(@tokens13, actions => 'Raku::AST'), List, 'Parsing produces a list (number)';

## 14
is fp-ebnf-parse(@tokens13, actions => 'Raku::AST').all ~~ List, True, 'Parsing produces a list of lists (number)';

## 15
is-deeply
        fp-ebnf-parse(@tokens13, actions => 'Raku::AST').head.tail.value>>.key,
        <EBNFRule EBNFRule EBNFRule>,
        'Value of the result is list of pairs with keys "EBNFRule" (number)';

## 16
is-deeply
        fp-ebnf-parse(@tokens13, actions => 'Raku::AST').head.tail.value>>.value>>.key,
        ("<digit>", "<number>", "<top>"),
        'Expected rule names (number)';

## 17
is-deeply
        fp-ebnf-parse($ebnfCode13, actions => 'Raku::AST').head.tail,
        fp-ebnf-parse(@tokens13, actions => 'Raku::AST').head.tail,
        'Same results for string and tokens (number)';

##===========================================================
## 18 - 23
##===========================================================
my $ebnfCode18 = q:to/END/;
<top> = 'a' <& 'b' <& 'c' <& 'd' | <right> ;
<right> = 'e' &> 'f' &> 'g' &> 'h' ;
END

my @tokens18 = $ebnfCode18.comb;

## 18
isa-ok fp-ebnf-parse(@tokens18.head.tail), List, 'Parsing produces a list (<& &>)';

## 19
is fp-ebnf-parse(@tokens18.head.tail).all ~~ List, True, 'Parsing produces a list of lists (<& &>)';

## 20
is-deeply
        fp-ebnf-parse(@tokens18, actions => 'Raku::AST').head.tail.value>>.key,
        <EBNFRule EBNFRule>,
        'Value of the result is list of pairs with keys "EBNFRule" (<& &>)';

## 21
is-deeply
        fp-ebnf-parse(@tokens18, actions => 'Raku::AST').head.tail.value>>.value>>.key,
        ("<top>", "<right>"),
        'Expected rule names (<& &>)';

## 22
is-deeply
        [fp-ebnf-parse(@tokens18, actions => 'Raku::AST').head.tail.value.head,],
        $[:EBNFRule("<top>" => :EBNFAlternatives((:EBNFSequencePickLeft((:EBNFTerminal("'a'"), :EBNFSequencePickLeft((:EBNFTerminal("'b'"), :EBNFSequencePickLeft((:EBNFTerminal("'c'"), :EBNFTerminal("'d'"))))))), :EBNFNonTerminal("<right>"))))],
        'Expected rule structure, <top> (<& &>)';

## 23
is-deeply
        [fp-ebnf-parse(@tokens18, actions => 'Raku::AST').head.tail.value[1],],
        $[:EBNFRule("<right>" => :EBNFSequencePickRight((:EBNFTerminal("'e'"), :EBNFSequencePickRight((:EBNFTerminal("'f'"), :EBNFSequencePickRight((:EBNFTerminal("'g'"), :EBNFTerminal("'h'"))))))))],
        'Expected rule structure, <right> (<& &>)';

##===========================================================
## 24
##===========================================================
my $ebnfCode24 = q:to/END/;
<top> = 'a' , 'b' , 'c' , 'd';
END

## 24
is-deeply
        [fp-ebnf-parse($ebnfCode24, actions => 'Raku::AST').head.tail.value.head,],
        $[:EBNFRule("<top>" => :EBNFSequence((:EBNFTerminal("'a'"), :EBNFTerminal("'b'"), :EBNFTerminal("'c'"), :EBNFTerminal("'d'"))))],
        'Expected rule structure, <top> (,)';

done-testing;
