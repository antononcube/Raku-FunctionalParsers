use v6.d;

class FunctionalParsers::Actions::Raku::EBNFParserPairs {
    has &.terminal = {Pair.new('EBNFTerminal', $_)};

    has &.non-terminal = {Pair.new('EBNFNonTerminal', $_)};

    has &.option = {Pair.new('EBNFOption', $_)};

    has &.repetition = {Pair.new('EBNFRepetition', $_)};

    has &.apply = {Pair.new('EBNFApply', ($_[1], $_[0]))};

    has &.sequence = {Pair.new('EBNFSequence', $_)};

    has &.alternatives = {$_ ~~ Positional && $_.elems > 1 ?? Pair.new('EBNFAlternatives', $_) !! $_.head};

    has &.parens = {$_};

    has &.node = {$_};

    has &.term = {$_ ~~ Positional && $_.elems > 1 ?? Pair.new('EBNFSequence', $_) !! $_.head};

    has &.expr = { self.alternatives.($_) };

    has &.rule = {Pair.new('EBNFRule', Pair.new($_[0], $_[1]))};

    has &.grammar = {Pair.new('EBNF', $_)}
}