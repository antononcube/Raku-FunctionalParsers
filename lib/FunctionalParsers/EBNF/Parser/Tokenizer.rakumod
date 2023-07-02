use v6.d;

use FunctionalParsers :shortcuts;

class FunctionalParsers::EBNF::Parser::Tokenizer {

    # Comment
    has &.pGComment = apply({ $_.flat.join ~ "\n"}, sequence(sp(token("(*")), many(satisfy({True})), token('*)')));

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

    # Symbol
    has &.pGSymbol is rw = apply({$_.flat.join}, alternatives(
            sp(token('=')),
            sp(symbol(',')), sp(token('<&')), sp(token('&>')),
            sp(symbol('|')),
            sp(symbol('(')), sp(symbol(')')),
            sp(symbol('[')), sp(symbol(']')),
            sp(symbol('{')), sp(symbol('}')),
            sp(token('<@')),
            sp(symbol(';'))));

    # Function
    has &.pGApplyFuncPack is rw = -> @x {
        apply({ ('${', $_.flat.join.substr(2, *-1), '}') }, pack(token('${'), many1(satisfy({$_ ~~ / <-[{}]> / })), sp(token('}'))))(@x)
    }

    # Text blob
    has &.pGText = apply({ "Text[{$_.flat.join}]" }, many1(satisfy({True})));

#    sp(self.pGComment),
#    sp(self.pGNonTerminal),
#    sp(self.pGTerminal),
#    sp(self.pGText),

    # Grammar
    has &.pEBNF = -> @x {
        apply({$_.flat},
                shortest(many(alternatives-first-match(
                        sp(self.pGComment),
                        sp(self.pGTerminal),
                        sp(self.pGNonTerminal),
                        sp(self.pGApplyFuncPack),
                        self.pGSymbol))))(@x)
    }

}