use v6.d;

use lib '.';
use lib './lib';

use FunctionalParsers::EBNF;
use Test;

plan *;

##===========================================================
## 1
##===========================================================
my $ebnfCode1 = "
<top> = 'a' , 'b' , 'c' ;
";

## 1
is-deeply fp-ebnf-parse($ebnfCode1, actions => 'Raku::AST').head.tail.Hash,
        {:EBNF((:EBNFRule("<top>" => :EBNFSequence((:EBNFTerminal("\"a\""), :EBNFTerminal("\"b\""), :EBNFTerminal("\"c\"")))),))},
        'Comma separated';

##===========================================================
## 2
##===========================================================
my $ebnfCode2 = "
<top> = 'a' <& 'b' <& 'c' ;
";

## 2
is-deeply fp-ebnf-parse($ebnfCode2, actions => 'Raku::AST').head.tail.Hash,
        ${:EBNF($(:EBNFRule("<top>" => :EBNFSequencePickLeft((:EBNFTerminal("\"a\""), :EBNFSequencePickLeft((:EBNFTerminal("\"b\""), :EBNFTerminal("\"c\"")))))),))},
        'Pick left separated';

##===========================================================
## 3
##===========================================================
my $ebnfCode3 = "
<top> = 'a' &> 'b' &> 'c' ;
";

## 3
is-deeply fp-ebnf-parse($ebnfCode3, actions => 'Raku::AST').head.tail.Hash,
        ${:EBNF($(:EBNFRule("<top>" => :EBNFSequencePickRight((:EBNFTerminal("\"a\""), :EBNFSequencePickRight((:EBNFTerminal("\"b\""), :EBNFTerminal("\"c\"")))))),))},
        'Pick right separated';

##===========================================================
## 4
##===========================================================
my $ebnfCode4 = "
<top> = 'a' &> 'b' , 'c' ;
";

## 4
is-deeply fp-ebnf-parse($ebnfCode4, actions => 'Raku::AST').head.tail.Hash,
        {:EBNF((:EBNFRule("<top>" => :EBNFSequencePickRight((:EBNFTerminal("\"a\""), :EBNFSequence((:EBNFTerminal("\"b\""), :EBNFTerminal("\"c\"")))))),))},
        'Pick right and comma separated';


##===========================================================
## 5
##===========================================================
my $ebnfCode5 = "
<top> = <a> &> <b> , <c> ;
";

## 5
is-deeply fp-ebnf-parse($ebnfCode5, actions => 'Raku::Grammar').head.tail.subst(/ \s+ /, ' ', :g).trim,
        'grammar FP { rule TOP { <.pA> <pB> <pC> } }',
        'Pick right and comma separated, Grammar';


##===========================================================
## 6
##===========================================================
my $ebnfCode6 = "
<top> = <a> &> <b> , <c> <& <d> ;
";

## 6
is-deeply fp-ebnf-parse($ebnfCode6, actions => 'Raku::Grammar').head.tail.subst(/ \s+ /, ' ', :g).trim,
        'grammar FP { rule TOP { <.pA> <pB> <pC> <.pD> } }',
        'Pick right, comma separated, pick left, Grammar';


##===========================================================
## 7
##===========================================================

## 7
is-deeply fp-ebnf-parse($ebnfCode6, actions => 'Raku::Code').head.tail.subst(/ \s+ /, ' ', :g).trim,
        'my &pTOP = sequence-pick-right(&pA, sequence(&pB, sequence-pick-left(&pC, &pD)));',
        'Pick right, comma separated, pick left, Cpode';

##===========================================================
## 8
##===========================================================
my $res8 = q:to/END/;
class FP {
  method pTOP(@x) { sequence-pick-right({self.pA($_)}, sequence({self.pB($_)}, sequence-pick-left({self.pC($_)}, {self.pD($_)})))(@x) }
  method FALLBACK ($name, |c) { "$name\(\)" }
  has &.parser is rw = -> @x { self.pTOP(@x) };
}
END

## 8
is-deeply fp-ebnf-parse($ebnfCode6, actions => 'Raku::Class').head.tail.subst(/ \s+ /, ' ', :g).trim,
        $res8.subst(/ \s+ /, ' ', :g).trim,
        'Pick right, comma separated, pick left, Class';

##===========================================================
## 9
##===========================================================
my $ebnfCode9 = "
<top> = <a> &> <b> , <c> <& <d> <& <e> ;
";

## 9
is-deeply fp-ebnf-parse($ebnfCode9, actions => 'Raku::Grammar').head.tail.subst(/ \s+ /, ' ', :g).trim,
        'grammar FP { rule TOP { <.pA> <pB> <pC> <.pD> <.pE> } }',
        'Pick right, comma separated, pick left, pick left, Grammar';


done-testing;
