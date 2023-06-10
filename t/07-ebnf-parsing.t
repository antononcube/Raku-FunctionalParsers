use v6.d;

use lib '.';
use lib './lib';

use FunctionalParsers;
use Test;


plan *;

##===========================================================
## 1 - 7
##===========================================================
my $ebnfCode1 = "
<top> = 'a' | 'b' ;
";

my @tokens1 = $ebnfCode1.split(/ \s /, :skip-empty);

## 1
isa-ok parse-ebnf(@tokens1), List, 'Parsing produces a list';

## 2
is parse-ebnf(@tokens1).all ~~ List, True, 'Parsing produces a list of lists';

## 3
is parse-ebnf(@tokens1).head.head, (), 'Empty non-parsed';

## 4
isa-ok parse-ebnf(@tokens1).head.tail, Pair;

## 5
is parse-ebnf(@tokens1).head.tail.key, "EBNF", 'Key of the result is "EBNF"';

## 6
is-deeply
        parse-ebnf(@tokens1).head.tail.value>>.key,
        ("EBNFRule",),
        'Value of the result is list of pairs with keys "EBNFRule"';

## 7
is-deeply
        parse-ebnf(@tokens1).head.tail.value.Hash,
        {EBNFRule => ("<top>" => :EBNFAlternatives(((:EBNFTerminal("'a'"),), (:EBNFTerminal("'b'"),))))},
        'Expected pairs';

##===========================================================
## 8 - 10
##===========================================================
my $ebnfCode8 = q:to/END/;
<b> = 'b' , [ '1' | '2' ] ;
END

my @tokens8 = $ebnfCode8.split(/ \s /, :skip-empty);

## 8
isa-ok parse-ebnf(@tokens8), List, 'Parsing produces a list (b opt)';

## 9
is parse-ebnf(@tokens8).all ~~ List, True, 'Parsing produces a list of lists (b opt)';

## 10
is-deeply
        parse-ebnf(@tokens8).head.tail.value.Hash,
        {:EBNFRule("<b>" => :EBNFAlternatives((:EBNFSequence((:EBNFTerminal("'b'"), :EBNFOption(:EBNFAlternatives(((:EBNFTerminal("'1'"),), (:EBNFTerminal("'2'"),)))))),)))},
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
isa-ok parse-ebnf(@tokens11), List, 'Parsing produces a list (number)';

## 12
is parse-ebnf(@tokens11).all ~~ List, True, 'Parsing produces a list of lists (number)';

## 13
is-deeply
        parse-ebnf(@tokens11).head.tail.value>>.key,
        <EBNFRule EBNFRule EBNFRule>,
        'Value of the result is list of pairs with keys "EBNFRule" (number)';

## 14
is-deeply
        parse-ebnf(@tokens11).head.tail.value>>.value>>.key,
        ("<digit>", "<number>", "<top>"),
        'Expected rule names (number)';

done-testing;