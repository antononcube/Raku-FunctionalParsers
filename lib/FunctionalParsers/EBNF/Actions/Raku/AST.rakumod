use v6.d;

use FunctionalParsers::EBNF::Actions::Common;

class FunctionalParsers::EBNF::Actions::Raku::AST
        does FunctionalParsers::EBNF::Actions::Common {

    has &.terminal = {Pair.new('EBNFTerminal', $_)};

    has &.non-terminal = {Pair.new('EBNFNonTerminal', $_)};

    has &.option = {Pair.new('EBNFOption', $_)};

    has &.repetition = {Pair.new('EBNFRepetition', $_)};

    has &.apply = {Pair.new('EBNFApply', ($_[1], $_[0]))};

    has &.sequence = {$_ ~~ Positional && $_.elems > 1 ?? Pair.new('EBNFSequence', $_) !! $_.head};

    has &.sequence-pick-left = {$_ ~~ Positional && $_.elems > 1 ?? Pair.new('EBNFSequencePickLeft', $_) !! $_.head};

    has &.sequence-pick-right = {$_ ~~ Positional && $_.elems > 1 ?? Pair.new('EBNFSequencePickRight', $_) !! $_.head};

    has &.alternatives = {$_ ~~ Positional && $_.elems > 1 ?? Pair.new('EBNFAlternatives', $_) !! $_.head};

    has &.parens = {$_};

    has &.node = {$_};

    has &.term = { self.alternatives.($_) };

    has &.expr = { self.alternatives.($_) };

    has &.rule = {Pair.new('EBNFRule', Pair.new($_[0], $_[1]))};

    has &.grammar is rw = {Pair.new('EBNF', $_)}
}