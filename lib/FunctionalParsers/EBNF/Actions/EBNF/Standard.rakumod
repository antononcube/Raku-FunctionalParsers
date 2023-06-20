use v6.d;

use FunctionalParsers::EBNF::Actions::Common;

class FunctionalParsers::EBNF::Actions::EBNF::Standard
        does FunctionalParsers::EBNF::Actions::Common {

    has &.terminal = {$_};

    has &.non-terminal = {'<' ~ $_.uc.subst(/\s/,'').subst(/^ [\' | \"] /, '').subst(/ [\' | \"] $ /, '') ~ '>'};

    has &.option = {"[ $_ ]"};

    has &.repetition = {"\{ $_ \}"};

    has &.apply = {"{$_[0]} <@ {$_[1]}"};

    has &.sequence = { $_ ~~ Positional && $_.elems > 1 ?? "{$_.join(' , ')}" !! $_ };

    has &.sequence-pick-left = { $_ ~~ Positional && $_.elems > 1 ?? "{$_.join(' <& ')}" !! $_ };

    has &.sequence-pick-right = { $_ ~~ Positional && $_.elems > 1 ?? "{$_.join(' &> ')}" !! $_ };

    has &.alternatives = { $_ ~~ Positional && $_.elems > 1 ?? "{$_.join(' | ')}" !! $_ };

    has &.parens = {$_};

    has &.node = {$_};

    has &.term = { self.alternatives.($_) };

    has &.expr = { self.alternatives.($_) };

    has &.rule = { "{self.non-terminal.($_[0])} = {$_[1]} ;" };

    has &.grammar = {$_}
}