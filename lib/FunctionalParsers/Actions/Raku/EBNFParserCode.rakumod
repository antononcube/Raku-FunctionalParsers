use v6.d;

class FunctionalParsers::Actions::Raku::EBNFParserCode {
    has Str $.prefix is rw = 'p';

    has &.terminal = {"symbol($_)"};

    has &.non-terminal = {"&{self.prefix}" ~ $_.uc.subst(/\s/,'').substr(1,*-1)};

    has &.option = {"option($_)"};

    has &.repetition = {"many($_)"};

    has &.apply = {"apply(&{$_[1]}, {$_[0]})"};

    has &.sequence = { $_ ~~ Positional && $_.elems > 1 ?? "sequence({$_.join(', ')})" !! $_ };

    has &.alternatives = { $_ ~~ Positional && $_.elems > 1 ?? "alternatives({$_.join(', ')})" !! $_ };

    has &.parens = {$_};

    has &.node = {$_};

    has &.term = { self.sequence.($_) };

    has &.expr = { self.alternatives.($_) };

    has &.rule = { "my {self.non-terminal.($_[0])} = {$_[1]};" };

    has &.grammar = {$_}
}