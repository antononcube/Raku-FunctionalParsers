use v6.d;

use FunctionalParsers::EBNF::Actions::Common;

class FunctionalParsers::EBNF::Actions::EBNF::Standard
        does FunctionalParsers::EBNF::Actions::Common {

    has &.terminal = {$_};

    has &.non-terminal = {'<' ~ self.modifier.(self.id-normalizer.($_)) ~ '>'};

    has &.option = {"[ $_ ]"};

    has &.repetition = {"\{ $_ \}"};

    has &.apply = {"{$_[0]} <@ {$_[1]}"};

    has &.sequence = { $_ ~~ Positional && $_.elems > 1 ?? "{$_.join(' , ')}" !! $_ };

    has &.sequence-pick-left = { $_ ~~ Positional && $_.elems > 1 ?? "{$_.join(' <& ')}" !! $_ };

    has &.sequence-pick-right = { $_ ~~ Positional && $_.elems > 1 ?? "{$_.join(' &> ')}" !! $_ };

    has &.sequence-any = {
        if $_ ~~ Positional && $_.elems > 1 {
            if $_ ~~ Str {
                $_
            } elsif $_[0] eq 'SequencePickLeft' {
                "{ $_[1] } <& { self.sequence-any.($_[2]) }"
            } elsif $_[0] eq 'SequencePickRight' {
                "{ $_[1] } &> { self.sequence-any.($_[2]) }"
            } else {
                # Sequence
                "{ $_[1] } , { self.sequence-any.($_[2]) }"
            }
        } else {
            $_
        }
    };

    has &.alternatives = { $_ ~~ Positional && $_.elems > 1 ?? "{$_.join(' | ')}" !! $_ };

    has &.parens = {$_};

    has &.node = {$_};

    has &.term = { self.alternatives.($_) };

    has &.expr = { self.alternatives.($_) };

    has &.rule = { "{self.non-terminal.($_[0])} = {$_[1]} ;" };

    has &.grammar = {$_.join("\n")}
}