use v6.d;

use FunctionalParsers :shortcuts;
use FunctionalParsers::EBNF::Actions::Raku::AST;

class FunctionalParsers::EBNF::Parser::Standard {

    has $.ebnfActions is rw = FunctionalParsers::EBNF::Actions::Raku::AST.new;

    # Comment
    has &.pGComment =  apply({ '#' ~ $_.flat.join }, pack(sp(token("(*")), many(satisfy({True})), token('*)')));

    # Terminal
    has &.pGTerminal is rw = -> @x {
        apply({ $_.flat.join },
                alternatives(
                sequence(symbol('\''), many1(satisfy({ $_ ne '\'' })), symbol('\'')),
                        sequence(symbol('"'), many1(satisfy({ $_ ne '"' })), symbol('"'))))(@x)
    };

    # Non-terminal
    has &.pGNonTerminal is rw = -> @x {
        apply({ $_.flat.join }, sequence(symbol('<'), many1(satisfy({ $_ ~~ / <alnum> | <:Pd> / })), symbol('>')))(@x)
    };

    # Option
    has &.pGOption = -> @x {
        apply($!ebnfActions.option, pack(sp(symbol('[')), sp(&!pGExpr), sp(symbol(']'))))(@x)
    };

    # Repetition
    has &.pGRepetition = -> @x {
        apply($!ebnfActions.repetition, pack(sp(symbol('{')), sp(&!pGExpr), sp(symbol('}'))))(@x)
    };

    # Parenthesized
    has &.pGParens = -> @x {
        pack(sp(symbol('(')), sp(&!pGExpr), sp(symbol(')')))(@x)
    }

    # Alternatives
    has &.pGNode = -> @x {
        alternatives(
                apply($!ebnfActions.terminal, sp(&!pGTerminal)),
                apply($!ebnfActions.non-terminal, sp(&!pGNonTerminal)),
                sp(&!pGParens),
                sp(&!pGRepetition),
                sp(&!pGOption))(@x)
    };

    # Standard sequence
    has &.pSepSeq is rw = sp(symbol(','));

    has &.pGTermSeq = -> @x {
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

    # Sequence with any separator
    has &!fformComma = { ('Sequence', $^a, $^b) };
    has &!fformLeft = { ('SequencePickLeft', $^a, $^b) };
    has &!fformRight = { ('SequencePickRight', $^a, $^b) };

    has &.pSepSeqAny = alternatives(
            apply({ &!fformComma }, &!pSepSeq),
            apply({ &!fformLeft }, sp(token('<&'))),
            apply({ &!fformRight }, sp(token('&>'))));


    has &.pGTermSeqAny = -> @x {
        apply($!ebnfActions.sequence-any, chain-right(&!pGNode, &!pSepSeqAny))(@x)
    };

    # Term
    has &.pGTerm = -> @x {
        #apply($!ebnfActions.term, alternatives(&!pGTermSeqAny))(@x)
        apply($!ebnfActions.term, alternatives(&!pGTermSeq, &!pGTermSeqL, &!pGTermSeqR, &!pGTermSeqAny))(@x)
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

    # Apply
    has &.pGApply is rw = -> @x {
        apply($!ebnfActions.apply, sequence(sp(&!pGTerm), sequence-pick-right(sp(token('<@')), sp(&!pGFunc))))(@x)
    }

    # Expression
    has &.pGExpr = -> @x {
        apply($!ebnfActions.expr, list-of(alternatives(sp(&!pGTerm), sp(&!pGApply)), sp(symbol('|'))))(@x)
    }

    # Rule
    has &.pAssign is rw = alternatives(symbol('='), token('::='));
    has &.pSepRule is rw = sp(symbol(';'));

    has &.pGRule = -> @x {
        apply($!ebnfActions.rule,
                sequence(
                sequence-pick-left(sp(&!pGNonTerminal), sp(&!pAssign)),
                        sequence-pick-left(sp(&!pGExpr), &!pSepRule)))(@x);
    }

    # Grammar
    has &.pEBNF = -> @x {
        apply($!ebnfActions.grammar, shortest(many(alternatives(sp(&!pGRule), sp(&!pGComment)))))(@x)
    }

}