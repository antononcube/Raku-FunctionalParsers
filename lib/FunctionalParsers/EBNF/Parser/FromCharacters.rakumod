use v6.d;

use FunctionalParsers :shortcuts;
use FunctionalParsers::EBNF::Actions::Raku::Pairs;

unit module FunctionalParsers::EBNF::Parser::FromCharacters;

#============================================================
# Self application
#============================================================

our $ebnfActions = FunctionalParsers::EBNF::Actions::Raku::Pairs.new;

sub pGTerminal(@x) {
    apply({ $_.flat.join },
            alternatives(
            sequence(symbol('\''), many1(satisfy({ $_ ne '\'' })), symbol('\'')),
            sequence(symbol('"'), many1(satisfy({ $_ ne '"' })), symbol('"'))))(@x)
}

sub pGNonTerminal(@x) {
    apply({ $_.flat.join }, sequence(symbol('<'), many1(satisfy({ $_ ~~ / <alnum> | <:Pd> /})), symbol('>')))(@x)
}

sub pGOption(@x) {
    apply($ebnfActions.option, pack(sp(symbol('[')), sp(&pGExpr), sp(symbol(']'))))(@x)
}

sub pGRepetition(@x) {
    apply($ebnfActions.repetition, pack(sp(symbol('{')), sp(&pGExpr), sp(symbol('}'))))(@x)
}

sub pGParens(@x) {
    pack(sp(symbol('(')), sp(&pGExpr), sp(symbol(')')))(@x)
}

sub pGNode(@x) { alternatives(
        apply($ebnfActions.terminal, sp(&pGTerminal)),
        apply($ebnfActions.non-terminal, sp(&pGNonTerminal)),
        sp(&pGParens),
        sp(&pGRepetition),
        sp(&pGOption))(@x)
}

my &seqSepForm = {Pair.new($^a,$^b)};
my &seqSep = alternatives(symbol(','), token('<&'), token('&>'));

sub pGTermSeq(@x) {
    apply($ebnfActions.sequence, list-of(&pGNode, sp(symbol(','))))(@x)
}

# Flatting is actually not desired
#my &seqLeftSepForm = { $^a ~~ Pair ?? ($^a, $^b) !! [|$^a, $^b].List };
my &seqLeftSepForm = { ($^a, $^b) };
my &seqLeftSep = apply({&seqLeftSepForm}, sp(token('<&')));
sub pGTermSeqL(@x) {
    apply($ebnfActions.sequence-pick-left, chain-left(&pGNode, &seqLeftSep))(@x)
}

# Flatting is actually not desired
#my &seqRightSepForm = { $^a ~~ Pair ?? ($^a, $^b) !! [|$^a, $^b].List };
my &seqRightSepForm = { ($^a, $^b) };
my &seqRightSep = apply({&seqRightSepForm}, sp(token('&>')));
sub pGTermSeqR(@x) {
    apply($ebnfActions.sequence-pick-right, chain-right(&pGNode, &seqRightSep))(@x)
}

sub pGTerm(@x) {
    apply($ebnfActions.term, alternatives(&pGTermSeq, &pGTermSeqL, &pGTermSeqR))(@x)
}

# What is an apply function?
# [X] Just a string
# [X] UNIX style code
# [ ] Raku style pure function
# [ ] WL style pure function
sub pGFunc(@x) {
    alternatives(
            apply({$_.flat.join}, many1(satisfy({$_ ~~ / ^ <alnum>+ $ /}))),
            apply({$_.flat.join.substr(1)}, sequence(alternatives(token('&{'), token('${')), many1(satisfy({$_ ~~ Str})), token('}'))))(@x)
}

sub pGApply(@x) {
    apply($ebnfActions.apply, sequence(sp(&pGTerm), sequence-pick-right(sp(token('<@')), sp(&pGFunc))))(@x)
}

sub pGExpr(@x) {
    apply($ebnfActions.expr, list-of(alternatives(sp(&pGTerm), sp(&pGApply)), sp(symbol('|'))))(@x)
}

sub pGRule(@x) {
    apply($ebnfActions.rule,
            sequence(
            sequence-pick-left(sp(&pGNonTerminal), sp(symbol('='))),
                    sequence-pick-left(sp(&pGExpr), sp(symbol(';')))))(@x);
}

our proto pEBNF(@x) is export {*}

multi sub pEBNF(@x) {
    apply($ebnfActions.grammar, shortest(many(sp(&pGRule))))(@x)
}

