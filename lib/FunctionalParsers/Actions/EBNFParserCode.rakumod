use v6.d;

class FunctionalParsers::Actions::EBNFParserCode {
    has &.terminal = {"symbol($_)"};

    has &.non-terminal = {"&p" ~ $_.uc.subst(/\s/,'').substr(1,*-1)};

    has &.option = {"option($_)"};

    has &.repetition = {"many($_)"};

    has &.sequence = { $_ ~~ Positional && $_.elems > 1 ?? "sequence({$_.join(', ')})" !! $_ };

    has &.alternatives = { $_ ~~ Positional && $_.elems > 1 ?? "alternatives({$_.join(', ')})" !! $_ };

    has &.parens = {$_};

    has &.node = {$_};

    has &.term = { self.sequence.($_) };

    has &.expr = { self.alternatives.($_) };

    has &.rule = { "my {self.non-terminal.($_[0])} = {$_[1]};" };

    has &.grammar = {$_}
}