use v6.d;

use FunctionalParsers :shortcuts;
use FunctionalParsers::EBNF::Parser::Standard;

class FunctionalParsers::EBNF::Parser::Styled
        is FunctionalParsers::EBNF::Parser::Standard {

    has $.style = 'Simple';

    has &.pSepRuleNewLine = sequence(option(many(satisfy({ $_ ~~ / \h / }))), many1(satisfy({ $_ ~~ / \v / })));

    has &.pIdentifier = apply({ $_.flat.join }, many1(satisfy({ $_ ~~ / [ <alnum> | <:Pd> ] / })));

    submethod TWEAK {
        given $!style {
            when $_.isa(Whatever) || $_ ~~ Str && $_.lc eq 'whatever' {

                # Non-terminals are words with or without angular brackets
                #self.pGNonTerminal = alternatives(pack(sp(symbol('<')), self.pIdentifier, symbol('>')), self.pIdentifier);
                self.pGNonTerminal = alternatives(self.pGNonTerminal, self.pIdentifier);

                # Sequence separation is whitespace
                self.pSepSeq = many1(alternatives(satisfy({ $_ ~~ / \h / }), sp(symbol(','))));

                # Assignment to LHS non-terminal
                self.pAssign = alternatives(token('->'), token('<-'), token('::='), symbol(':='), symbol('='), token(':'));

                # Rules are separate with new-line
                self.pSepRule = alternatives(sp(symbol(';')), self.pSepRuleNewLine);
            }

            when $_ ~~ Str && $_.lc ∈ <simple simpler> {

                # Non-terminals are words without angular brackets
                self.pGNonTerminal = self.pIdentifier;

                # Sequence separation is whitespace
                self.pSepSeq = many1(satisfy({ $_ ~~ / \h / }));

                # Assignment to LHS non-terminal
                self.pAssign = token('->');

                # Rules are separate with new-line
                self.pSepRule = self.pSepRuleNewLine;
            }

            when $_ ~~ Str && $_.lc ∈ <g4 antlr> {

                # Sequence separation is whitespace
                self.pSepSeq = many1(satisfy({ $_ ~~ / \h / }));

                # Assignment to LHS non-terminal
                self.pAssign = token(':');

                # Rules are separate with new-line
                self.pSepRule = self.pSepRuleNewLine;
            }

            when $_ ~~ Str && $_.lc ∈ <standard default> {
                # Do nothing
            }

            default {
                note "Do not how to process the theme spec $_.";
            }
        }
    }
}