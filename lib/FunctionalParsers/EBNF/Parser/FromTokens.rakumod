use v6.d;

use FunctionalParsers :shortcuts;
use FunctionalParsers::EBNF::Parser::Standard;

class FunctionalParsers::EBNF::Parser::FromTokens 
        is FunctionalParsers::EBNF::Parser::Standard {
    
    sub is-quoted($x) { $x.match(/ ^ [ \' .*? \' |  \" .*? \" ] $ /).Bool };

    sub is-ebnf-symbol($x) { $x ∈ ['|', '&', '&>', '<&', ';', ','] };

    sub is-non-terminal($x) { $x.match(/ ^ '<' <-[<>]>+ '>' /).Bool }

    submethod TWEAK {
        self.pGTerminal = -> @x {
            satisfy({ ($_ ~~ Str) && is-quoted($_) })(@x)
        };

        self.pGNonTerminal = -> @x {
            satisfy({
                my $res = ($_ ~~ Str) && is-non-terminal($_) && !is-ebnf-symbol($_);
                $res
            })(@x)
        };

        self.seqLeftSep = apply({ self.seqLeftSepForm }, sp(symbol('<&')));
        self.seqRightSep = apply({ self.seqRightSepForm }, sp(symbol('&>')));

        self.pGFunc = -> @x {
            #alternatives(satisfy({$_ ~~ Str}), curly-bracketed(many(satisfy({$_ ~~ Str}))))(@x)
            satisfy({ $_ ~~ Str })(@x)
        };

        self.pGApply = -> @x {
            apply(self.ebnfActions.apply, sequence(self.pGTerm, sequence-pick-right(symbol('<@'), self.pGFunc)))(@x)
        };
    }
}