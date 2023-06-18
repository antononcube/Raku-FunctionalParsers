use v6.d;

class FunctionalParsers::EBNF::Actions::WL::Code {
    has Str $.prefix is rw = 'p';
    has &.modifier = {$_.uc};

    has &.terminal = {"ParseSymbol[{$_.subst('\'','"'):g}]"};

    has &.non-terminal = {"{self.prefix}" ~ self.modifier.($_.subst(/\s/,'').substr(1,*-1))};

    has &.option = {"ParseOption[$_]"};

    has &.repetition = {"ParseMany[$_]"};

    has &.apply = {"ParseApply[{$_[1]}, {$_[0]}]"};

    has &.sequence = { $_ ~~ Positional && $_.elems > 1 ?? "ParseSequentialComposition[{$_.join(', ')}]" !! $_ };

    has &.sequence-pick-left = {
        $_ ~~ Str ?? $_ !! "ParseSequentialCompositionPickLeft[{self.sequence-pick-left.($_[0])}, {$_[1]}]"
    };

    has &.sequence-pick-right = {
        $_ ~~ Str ?? $_ !! "ParseSequentialCompositionPickRight[{$_[0]}, {self.sequence-pick-right.($_[1])}]"
    };

    has &.alternatives = { $_ ~~ Positional && $_.elems > 1 ?? "ParseAlternativeComposition[{$_.join(', ')}]" !! $_ };

    has &.parens = {$_};

    has &.node = {$_};

    has &.term = { self.sequence.($_) };

    has &.expr = { self.alternatives.($_) };

    has &.rule = { "{self.non-terminal.($_[0])} = {$_[1]};" };

    has &.grammar = {$_}
}