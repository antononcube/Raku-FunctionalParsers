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
                self.pAssign = alternatives(token('->'), token('→'), token('<-'), token('::='), token(':='), token('='), token(':'));

                # Rules are separated with ';', '.' or "\n"
                self.pSepRule = alternatives(sp(symbol(';')),  sp(symbol('.')), self.pSepRuleNewLine);
            }

            when $_ ~~ Str && $_.lc ∈ <simple> {

                # Non-terminals are words without angular brackets
                self.pGNonTerminal = self.pIdentifier;

                # Sequence separation is whitespace
                self.pSepSeq = many1(satisfy({ $_ ~~ / \h / }));

                # Assignment to LHS non-terminal
                self.pAssign = alternatives(token('->'), token('→'), token('='), token(':='), token('::='));

                # Rules are separated with new-line
                self.pSepRule = self.pSepRuleNewLine;
            }

            when $_ ~~ Str && $_.lc ∈ <relaxed simpler> {

                # Non-terminals can be words without angular brackets
                self.pGNonTerminal = alternatives(self.pGNonTerminal, self.pIdentifier);

                # Sequence separation can be both comma or whitespace
                self.pSepSeq = alternatives(self.pSepSeq, many1(satisfy({ $_ ~~ / \h / })));

                # Assignment to LHS non-terminal
                self.pAssign = alternatives(token('->'), token('→'), token('='), token(':='), token('::='));

                # Rules are separated with ';' or '.' because this makes the parsing ≈10 faster.
                self.pSepRule = alternatives(self.pSepRule, sp(symbol('.')));
            }

            when $_ ~~ Str && $_.lc ∈ <inverted> {

                # Terminals can are words without quotes
                self.pGTerminal = alternatives(self.pGTerminal, self.pIdentifier);

                # Sequence separation is whitespace
                self.pSepSeq = many1(alternatives(satisfy({ $_ ~~ / \h / }), sp(symbol(','))));

                # Assignment to LHS non-terminal
                self.pAssign = alternatives(token('->'), token('→'), token('='), token(':='), token('::='));

                # Rules are separated with "\n"
                self.pSepRule = self.pSepRuleNewLine;
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
                my @styles = <antlr default g4 inverted simple simpler standard relaxed>;
                note "Do not how to process the style spec $_. Expected style specs are '{@styles.join("', '")}', or Whatever.";
            }

        }

        # Using the redefinition of self.pSepSeq
        # Does not take care of "tokenized"
        self.pSepSeqAny = alternatives(
                apply({ self.fformComma }, self.pSepSeq),
                apply({ self.fformLeft }, sp(token('<&'))),
                apply({ self.fformRight }, sp(token('&>'))));
    }

    method normalize-rule-separation(Str $ebnf) {
        return $ebnf.split(/ \n | ';' /, :skip-empty).join(" ;\n") ~ ";";
    }
}