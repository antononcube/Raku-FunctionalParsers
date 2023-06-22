use v6.d;

use FunctionalParsers :shortcuts;
use FunctionalParsers::EBNF::Actions::Raku::AST;

class FunctionalParsers::EBNF::Parser::Standard {

    has $.ebnfActions is rw = FunctionalParsers::EBNF::Actions::Raku::AST.new;

    has &.pGTerminal is rw = -> @x {
        apply({ $_.flat.join },
                alternatives(
                sequence(symbol('\''), many1(satisfy({ $_ ne '\'' })), symbol('\'')),
                        sequence(symbol('"'), many1(satisfy({ $_ ne '"' })), symbol('"'))))(@x)
    };

    has &.pGNonTerminal is rw = -> @x {
        apply({ $_.flat.join }, sequence(symbol('<'), many1(satisfy({ $_ ~~ / <alnum> | <:Pd> / })), symbol('>')))(@x)
    };

    has &.pGOption = -> @x {
        apply($!ebnfActions.option, pack(sp(symbol('[')), sp(&!pGExpr), sp(symbol(']'))))(@x)
    };

    has &.pGRepetition = -> @x {
        apply($!ebnfActions.repetition, pack(sp(symbol('{')), sp(&!pGExpr), sp(symbol('}'))))(@x)
    };

    has &.pGParens = -> @x {
        pack(sp(symbol('(')), sp(&!pGExpr), sp(symbol(')')))(@x)
    }

    has &.pGNode = -> @x {
        alternatives(
                apply($!ebnfActions.terminal, sp(&!pGTerminal)),
                apply($!ebnfActions.non-terminal, sp(&!pGNonTerminal)),
                sp(&!pGParens),
                sp(&!pGRepetition),
                sp(&!pGOption))(@x)
    };

    has &.pSepSeq is rw = sp(symbol(','));

    has &.pGTermSeq= -> @x {
        apply($!ebnfActions.sequence, list-of(&!pGNode, &!pSepSeq))(@x)
    };

    # Flatting is actually not desired
    #my &seqLeftSepForm = { $^a ~~ Pair ?? ($^a, $^b) !! [|$^a, $^b].List };
    has &.seqLeftSepForm = { ($^a, $^b) };
    has &.seqLeftSep is rw = apply({ &!seqLeftSepForm }, sp(token('<&')));
    has &.pGTermSeqL = -> @x {
        apply($!ebnfActions.sequence-pick-left, chain-left(&!pGNode, &!seqLeftSep))(@x)
    };

    # Flatting is actually not desired
    #my &seqRightSepForm = { $^a ~~ Pair ?? ($^a, $^b) !! [|$^a, $^b].List };
    has &.seqRightSepForm = { ($^a, $^b) };
    has &.seqRightSep is rw = apply({ &!seqRightSepForm }, sp(token('&>')));
    has &.pGTermSeqR = -> @x {
        apply($!ebnfActions.sequence-pick-right, chain-right(&!pGNode, &!seqRightSep))(@x)
    };

    has &.pGTerm = -> @x {
        apply($!ebnfActions.term, alternatives(&!pGTermSeq, &!pGTermSeqL, &!pGTermSeqR))(@x)
    };

    # What is an apply function?
    # [X] Just a string
    # [X] UNIX style code
    # [ ] Raku style pure function
    # [ ] WL style pure function
    has &.pGFunc is rw = -> @x {
        alternatives(
                apply({ $_.flat.join }, many1(satisfy({ $_ ~~ / <alnum> | <:Pd> / }))),
                apply({ $_.flat.join.substr(1) }, sequence(alternatives(token('&{'), token('${')),
                many1(satisfy({ $_ ~~ Str })), token('}'))))(@x)
    }

    has &.pGApply is rw = -> @x {
        apply($!ebnfActions.apply, sequence(sp(&!pGTerm), sequence-pick-right(sp(token('<@')), sp(&!pGFunc))))(@x)
    }

    has &.pGExpr = -> @x {
        apply($!ebnfActions.expr, list-of(alternatives(sp(&!pGTerm), sp(&!pGApply)), sp(symbol('|'))))(@x)
    }

    has &.pAssign is rw = alternatives(symbol('='), token('::='));
    has &.pSepRule is rw = sp(symbol(';'));

    has &.pGRule = -> @x {
        apply($!ebnfActions.rule,
                sequence(
                sequence-pick-left(sp(&!pGNonTerminal), sp(&!pAssign)),
                        sequence-pick-left(sp(&!pGExpr), &!pSepRule)))(@x);
    }

    has &.pEBNF = -> @x {
        apply($!ebnfActions.grammar, shortest(many(sp(&!pGRule))))(@x)
    }

}