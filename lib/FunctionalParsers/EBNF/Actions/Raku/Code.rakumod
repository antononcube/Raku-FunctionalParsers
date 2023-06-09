use v6.d;

use FunctionalParsers::EBNF::Actions::Common;

class FunctionalParsers::EBNF::Actions::Raku::Code
        does FunctionalParsers::EBNF::Actions::Common {

    has &.terminal = {"symbol($_)"};

    has &.non-terminal = {"&{self.prefix}" ~ self.modifier.(self.id-normalizer.($_))};

    has &.option = {"option($_)"};

    has &.repetition = {"many($_)"};

    has &.apply = {"apply(&{$_[1]}, {$_[0]})"};

    has &.sequence = { $_ ~~ Positional && $_.elems > 1 ?? "sequence({$_.join(', ')})" !! $_ };

    has &.sequence-pick-left = {
        $_ ~~ Str ?? $_ !! "sequence-pick-left({self.sequence-pick-left.($_[0])}, {$_[1]})"
    };

    has &.sequence-pick-right = {
        $_ ~~ Str ?? $_ !! "sequence-pick-right({$_[0]}, {self.sequence-pick-right.($_[1])})"
    };

    has &.sequence-any = {
        if $_ ~~ Positional && $_.elems > 1 {
            "{self.ast-head-to-func{$_[0]}}({$_[1]}, {self.sequence-any.($_[2])})"
        } else {
            $_
        }
    };

    has &.alternatives = { $_ ~~ Positional && $_.elems > 1 ?? "alternatives({$_.join(', ')})" !! $_ };

    has &.parens = {"($_)"};

    has &.node = {$_};

    has &.term = { self.sequence-any.($_) };

    has &.expr = { self.alternatives.($_) };

    has &.rule = { "my {self.non-terminal.($_[0])} = {$_[1]};" };

    has &.grammar = {$_}
}