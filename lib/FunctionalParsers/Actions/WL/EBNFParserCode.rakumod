use v6.d;

class FunctionalParsers::Actions::WL::EBNFParserCode {
    has Str $.prefix is rw = 'p';

    has &.terminal = {"ParseSymbol[{$_.subst('\'','"'):g}]"};

    has &.non-terminal = {"{self.prefix}" ~ $_.uc.subst(/\s/,'').substr(1,*-1)};

    has &.option = {"ParseOption[$_]"};

    has &.repetition = {"ParseMany[$_]"};

    has &.sequence = { $_ ~~ Positional && $_.elems > 1 ?? "ParseSequentialComposition[{$_.join(', ')}]" !! $_ };

    has &.alternatives = { $_ ~~ Positional && $_.elems > 1 ?? "ParseAlternativeComposition[{$_.join(', ')}]" !! $_ };

    has &.parens = {$_};

    has &.node = {$_};

    has &.term = { self.sequence.($_) };

    has &.expr = { self.alternatives.($_) };

    has &.rule = { "{self.non-terminal.($_[0])} = {$_[1]};" };

    has &.grammar = {$_}
}