use v6.d;

use FunctionalParsers::EBNF::Actions::Common;

class FunctionalParsers::EBNF::Actions::WL::Grammar
        does FunctionalParsers::EBNF::Actions::Common {

    method setup-code {''}

    has &.terminal = {"{$_.subst('\'','"'):g}"};

    has &.non-terminal = {"\"{self.prefix}" ~ self.modifier.($_.subst(/\s/,'').substr(1,*-1)) ~ '"'};

    has &.option = {"OptionalElement[$_]"};

    has &.repetition = {"$_.."};

    has &.apply = {"{$_[0]} :> {$_[1].subst(/^ '{'/, '').subst(/'}' $/, '')}"};

    has &.sequence = { $_ ~~ Positional && $_.elems > 1 ?? "FixedOrder[{$_.join(', ')}]" !! $_ };

    has &.sequence-pick-left = { self.sequence.($_) };

    has &.sequence-pick-right = { self.sequence.($_) };

    has &.sequence-any = {
        if $_ ~~ Positional && $_.elems > 1 {
            "FixedOrder[{$_[1]}, {self.sequence-any.($_[2])}]"
        } else {
            $_
        }
    };

    has &.alternatives = { $_ ~~ Positional && $_.elems > 1 ?? "{$_.join(' | ')}" !! $_ };

    has &.parens = {$_};

    has &.node = {$_};

    has &.term = { self.sequence-any.($_) };

    has &.expr = { self.alternatives.($_) };

    has &.rule = { "{self.non-terminal.($_[0])} -> {$_[1]}" };

    has &.grammar = {
        my @rules = $_.grep({ !$_.starts-with( '"' ~ self.top-rule-name) });
        my $topRule = $_.grep({ $_.starts-with( '"' ~ self.top-rule-name) }).head;
        "GrammarRules[\{{$topRule}\}, \{" ~ @rules.join(',') ~ '}]'
    }
}