use v6.d;

use FunctionalParsers :shortcuts;
use FunctionalParsers::EBNF::Parser::Standard;

class FunctionalParsers::EBNF::Parser::Themed
        is FunctionalParsers::EBNF::Parser::Standard {

    has $.theme = 'Simpler';

    has &.pSepRuleNewLine = sequence(option(many(satisfy({ $_ ~~ / \h / }))), many1(satisfy({ $_ ~~ / \v / })));

    has &.pIdentifier = apply({ $_.flat.join }, many1(satisfy({ $_ ~~ / [<alnum> | <:Pd> ] / })));

    submethod TWEAK {
        given $!theme {
            when $_.isa(Whatever) {

                # Non-terminals are words with or without angular brackets
                self.pGNonTerminal = alternatives(self.pGNonTerminal, self.pIdentifier);

                # Sequence separation is whitespace
                self.pSepSeq = many1(satisfy({ $_ ~~ / \h / }));

                # Assignment to LHS token
                self.pAssign = alternatives(token('->'), token('<-'), token('::='), symbol('='));

                # Rules are separate with new-line
                self.pSepRule = alternatives(sp(symbol(';')), self.pSepRuleNewLine);
            }

            when $_ ~~ Str && $_.lc ∈ <simple simpler> {

                # Non-terminals are words without angular brackets
                self.pGNonTerminal = self.pIdentifier;

                # Sequence separation is whitespace
                self.pSepSeq = many1(satisfy({ $_ ~~ / \h / }));

                # Assignment to LHS token
                self.pAssign = token('->');

                # Rules are separate with new-line
                self.pSepRule = self.pSepRuleNewLine;
            }

            when $_ ~~ Str && $_.lc ∈ <g4 antlr> {

                # Sequence separation is whitespace
                self.pSepSeq = many1(satisfy({ $_ ~~ / \h / }));

                # Assignment to LHS token
                self.pAssign = token(':');

                # Rules are separate with new-line
                self.pSepRule = self.pSepRuleNewLine;
            }

            default {
                note "Do not how to process the theme spec $_.";
            }
        }
    }
}