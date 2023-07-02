use v6.d;

use FunctionalParsers::EBNF::Actions::MermaidJS::ASTTracer;
use FunctionalParsers::EBNF::Actions::MermaidJS::Common;
use FunctionalParsers::EBNF::Actions::Raku::AST;

class FunctionalParsers::EBNF::Actions::MermaidJS::Graph
        does FunctionalParsers::EBNF::Actions::MermaidJS::Common
        does FunctionalParsers::EBNF::Actions::MermaidJS::ASTTracer
        is FunctionalParsers::EBNF::Actions::Raku::AST {

    submethod TWEAK {
        self.grammar = {
            self.nodes = Empty;
            self.rules = Empty;
            self.tranceIndex = 0;
            my $res = Pair.new('EBNF', $_);
            self.trace($res)
        }
    }
}