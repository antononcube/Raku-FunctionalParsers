use v6.d;

use FunctionalParsers :shortcuts;
use FunctionalParsers::EBNF::Parser::Standard;

class FunctionalParsers::EBNF::Parser::SimplerStyle
        is FunctionalParsers::EBNF::Parser::Standard {

    submethod TWEAK {
        self.pGNonTerminal = -> @x {
            #apply({ note $_.flat.join; $_.flat.join }, many1(satisfy({ $_ !~~ / <?['"\s]> / })))(@x)
            apply({ $_.flat.join }, many1(satisfy({ $_ ~~ / <alnum> / })))(@x)
        };

        self.pSepSeq = many1(satisfy({ $_ ~~ / \h / }));

        self.pAssign = token('->');

        self.pSepRule = sequence(option(many(satisfy({ $_ ~~ / \h / }))), many1(satisfy({ $_ ~~ / \v / })));

    }}