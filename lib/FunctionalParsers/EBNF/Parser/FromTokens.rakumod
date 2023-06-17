use v6.d;

use FunctionalParsers;
use FunctionalParsers::EBNF::Actions::Raku::Pairs;

unit module FunctionalParsers::EBNF::Parser::FromTokens;

#============================================================
# Self application
#============================================================

our $ebnfActions = FunctionalParsers::EBNF::Actions::Raku::Pairs.new;

sub is-quoted($x) { $x.match(/ ^ [ \' .*? \' |  \" .*? \" ] $ /).Bool };

sub is-ebnf-symbol($x) { $x ∈ ['|', '&', '&>', '<&', ';', ','] };

sub is-non-terminal($x) { $x.match(/ ^ '<' <-[<>]>+ '>' /).Bool }

sub pGTerminal(@x) {
    satisfy({ ($_ ~~ Str) && is-quoted($_) })(@x)
}

sub pGNonTerminal(@x) {
    satisfy({
        my $res = ($_ ~~ Str) && is-non-terminal($_) && !is-ebnf-symbol($_);
        $res})(@x)
}

sub pGOption(@x) {
    apply($ebnfActions.option, bracketed(&pGExpr))(@x)
}

sub pGRepetition(@x) {
    apply($ebnfActions.repetition, curly-bracketed(&pGExpr))(@x)
}

sub pGParens(@x) {
    parenthesized(&pGExpr)(@x)
}

sub pGNode(@x) { alternatives(
        apply($ebnfActions.terminal, &pGTerminal),
        apply($ebnfActions.non-terminal, &pGNonTerminal),
        &pGParens,
        &pGRepetition,
        &pGOption)(@x)
}

my &seqSepForm = {Pair.new($^a,$^b)};
my &seqSep = alternatives(symbol(','), symbol('<&'), symbol('&>'));

sub pGTermSeq(@x) {
    apply($ebnfActions.sequence, list-of(&pGNode, symbol(',')))(@x)
}

# Flatting is actually not desired
#my &seqLeftSepForm = { $^a ~~ Pair ?? ($^a, $^b) !! [|$^a, $^b].List };
my &seqLeftSepForm = { ($^a, $^b) };
my &seqLeftSep = apply({&seqLeftSepForm}, symbol('<&'));
sub pGTermSeqL(@x) {
    apply($ebnfActions.sequence-pick-left, chain-left(&pGNode, &seqLeftSep))(@x)
}

# Flatting is actually not desired
#my &seqRightSepForm = { $^a ~~ Pair ?? ($^a, $^b) !! [|$^a, $^b].List };
my &seqRightSepForm = { ($^a, $^b) };
my &seqRightSep = apply({&seqRightSepForm}, symbol('&>'));
sub pGTermSeqR(@x) {
    apply($ebnfActions.sequence-pick-right, chain-right(&pGNode, &seqRightSep))(@x)
}

sub pGTerm(@x) {
    apply($ebnfActions.term, alternatives(&pGTermSeq, &pGTermSeqL, &pGTermSeqR))(@x)
}

# What is an apply function?
# [X] Just a string
# [ ] Raku style pure function
# [ ] WL style pure function
sub pGFunc(@x) {
    #alternatives(satisfy({$_ ~~ Str}), curly-bracketed(many(satisfy({$_ ~~ Str}))))(@x)
    satisfy({$_ ~~ Str})(@x)
}

sub pGApply(@x) {
    apply($ebnfActions.apply, sequence(&pGTerm, sequence-pick-right(symbol('<@'), &pGFunc)))(@x)
}

sub pGExpr(@x) {
    apply($ebnfActions.expr, list-of(alternatives(&pGTerm, &pGApply), symbol('|')))(@x)
}

sub pGRule(@x) {
    apply($ebnfActions.rule,
            sequence(
            sequence-pick-left(&pGNonTerminal, symbol('=')),
                    sequence-pick-left(&pGExpr, symbol(';'))))(@x);
}

our proto pEBNF(@x) is export {*}

multi sub pEBNF(@x) {
    apply($ebnfActions.grammar, shortest(many(&pGRule)))(@x)
}

