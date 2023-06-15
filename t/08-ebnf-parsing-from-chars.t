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
isa-ok parse-ebnf(@tokens1, :!tokenized), List, 'Parsing produces a list';

## 2
is parse-ebnf(@tokens1, :!tokenized).all ~~ List, True, 'Parsing produces a list of lists';

## 3
is parse-ebnf(@tokens1, :!tokenized).head.head.trim, '', 'Empty non-parsed';

## 4
isa-ok parse-ebnf(@tokens1, :!tokenized).head.tail, Pair;

## 5
is parse-ebnf(@tokens1, :!tokenized).head.tail.key, "EBNF", 'Key of the result is "EBNF"';

## 6
is-deeply
        parse-ebnf(@tokens1, :!tokenized).head.tail.value>>.key,
        ("EBNFRule",),
        'Value of the result is list of pairs with keys "EBNFRule"';

## 7
is-deeply
        parse-ebnf(@tokens1, :!tokenized).head.tail.value.Hash,
        {:EBNFRule("<top>" => :EBNFAlternatives((:EBNFTerminal("'a'"), :EBNFTerminal("'b'"))))},
        'Expected pairs';

## 8
is-deeply
        parse-ebnf($ebnfCode1),
        parse-ebnf(@tokens1, :!tokenized),
        'Same results for string and tokens';

##===========================================================
## 9 - 12
##===========================================================
my $ebnfCode9 = q:to/END/;
<b> = 'b' , [ '1' | '2' ] ;
END

my @tokens9 = $ebnfCode9.comb;

## 9
isa-ok parse-ebnf(@tokens9, :!tokenized), List, 'Parsing produces a list (b opt)';

## 10
is parse-ebnf(@tokens9, :!tokenized).all ~~ List, True, 'Parsing produces a list of lists (b opt)';

## 11
is-deeply
        parse-ebnf(@tokens9, :!tokenized).head.tail.value.Hash,
        {:EBNFRule("<b>" => :EBNFSequence((:EBNFTerminal("'b'"), :EBNFOption(:EBNFAlternatives((:EBNFTerminal("'1'"), :EBNFTerminal("'2'")))))))},
        'Expected pairs (b opt)';

## 12
is-deeply
        parse-ebnf($ebnfCode9),
        parse-ebnf(@tokens9, :!tokenized),
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
isa-ok parse-ebnf(@tokens13, :!tokenized), List, 'Parsing produces a list (number)';

## 14
is parse-ebnf(@tokens13, :!tokenized).all ~~ List, True, 'Parsing produces a list of lists (number)';

## 15
is-deeply
        parse-ebnf(@tokens13, :!tokenized).head.tail.value>>.key,
        <EBNFRule EBNFRule EBNFRule>,
        'Value of the result is list of pairs with keys "EBNFRule" (number)';

## 16
is-deeply
        parse-ebnf(@tokens13, :!tokenized).head.tail.value>>.value>>.key,
        ("<digit>", "<number>", "<top>"),
        'Expected rule names (number)';

## 17
is-deeply
        parse-ebnf($ebnfCode13),
        parse-ebnf(@tokens13, :!tokenized),
        'Same results for string and tokens (number)';

done-testing;
