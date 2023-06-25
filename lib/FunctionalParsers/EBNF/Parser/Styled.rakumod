use v6.d;

use FunctionalParsers :shortcuts;
use FunctionalParsers::EBNF::Parser::Standard;

class FunctionalParsers::EBNF::Parser::Styled
        is FunctionalParsers::EBNF::Parser::Standard {

    has $.style = 'Relaxed';

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

            when $_ ~~ Str && $_.lc ∈ <simple> {

                # Non-terminals are words without angular brackets
                self.pGNonTerminal = self.pIdentifier;

                # Sequence separation is whitespace
                self.pSepSeq = many1(satisfy({ $_ ~~ / \h / }));

                # Assignment to LHS non-terminal
                self.pAssign = token('->');

                # Rules are separate with new-line
                self.pSepRule = self.pSepRuleNewLine;
            }

            when $_ ~~ Str && $_.lc ∈ <relaxed simpler> {

                # Non-terminals are words without angular brackets
                self.pGNonTerminal = alternatives(self.pGNonTerminal, self.pIdentifier);

                # Sequence separation is whitespace
                self.pSepSeq = alternatives(self.pSepSeq, many1(satisfy({ $_ ~~ / \h / })));

                # Assignment to LHS non-terminal
                self.pAssign = alternatives(token('->'), symbol('='), symbol('::='));

                # Rules are separated with ';' or '.' because this makes the parsing ≈10 faster.
                self.pSepRule = alternatives(self.pSepRule, sp(symbol('.')));
            }

            when $_ ~~ Str && $_.lc ∈ <antlr g4> {

                # Non-terminals are words without angular brackets
                self.pGNonTerminal = self.pIdentifier;

                # Sequence separation is whitespace
                self.pSepSeq = many1(satisfy({ $_ ~~ / \h / }));

                # Assignment to LHS non-terminal
                self.pAssign = token(':');

                # Rules are separate with new-line
                self.pSepRule = self.pSepRuleNewLine;
            }

            when $_ ~~ Str && $_.lc ∈ <default standard> {
                # Do nothing
            }

            default {
                note "Do not how to process the theme spec $_. Expected theme specs are <antlr default simple relaxed> or Whatever.";
            }
        }
    }

    method normalize-rule-separation(Str $ebnf) {
        return $ebnf.split(/ \n | ';' /, :skip-empty).join(" ;\n") ~ ";";
    }
}