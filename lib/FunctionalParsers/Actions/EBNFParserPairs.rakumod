use v6.d;

class FunctionalParsers::Actions::EBNFParserPairs {
    has &.terminal = {Pair.new('EBNFterminal', $_)};

    has &.non-terminal = {Pair.new('EBNFNonTerminal', $_)};

    has &.option = {Pair.new('EBNFOption', $_)};

    has &.repetition = {Pair.new('EBNFRepetition', $_)};

    has &.sequence = {Pair.new('EBNFSequence', $_)};

    has &.alternatives = {Pair.new('EBNFAlternatives', $_)};

    has &.parens = {$_};

    has &.node = {$_};

    has &.term = {$_ ~~ Positional && $_.elems > 1 ?? Pair.new('EBNFSequence', $_) !! $_};

    has &.expr = {$_ ~~ Positional && $_.elems > 1 ?? Pair.new('EBNFAlternatives', $_) !! $_};

    has &.rule = {Pair.new('EBNFRule', $_)};

    has &.grammar = {Pair.new('EBNF', $_)}
}