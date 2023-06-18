use v6.d;

use FunctionalParsers::EBNF::Actions::Common;

class FunctionalParsers::EBNF::Actions::WL::Grammar
        does FunctionalParsers::EBNF::Actions::Common {

    has &.terminal = {"{$_.subst('\'','"'):g}"};

    has &.non-terminal = {"\"{self.prefix}" ~ self.modifier.($_.subst(/\s/,'').substr(1,*-1)) ~ '"'};

    has &.option = {"OptionalElement[$_]"};

    has &.repetition = {"$_.."};

    has &.apply = {"{$_[0]} :> {$_[1].subst(/^ '{'/, '').subst(/'}' $/, '')}"};

    has &.sequence = { $_ ~~ Positional && $_.elems > 1 ?? "FixedOrder[{$_.join(', ')}]" !! $_ };

    has &.sequence-pick-left = { self.sequence.($_) };

    has &.sequence-pick-right = { self.sequence.($_) };

    has &.alternatives = { $_ ~~ Positional && $_.elems > 1 ?? "{$_.join(' | ')}" !! $_ };

    has &.parens = {$_};

    has &.node = {$_};

    has &.term = { self.sequence.($_) };

    has &.expr = { self.alternatives.($_) };

    has &.rule = { "{self.non-terminal.($_[0])} -> {$_[1]}" };

    has &.grammar = {
        my @rules = $_.grep({ !$_.starts-with( '"' ~ self.topRuleName) });
        my $topRule = $_.grep({ $_.starts-with( '"' ~ self.topRuleName) }).head;
        "GrammarRules[\{{$topRule}\}, \{" ~ @rules.join(',') ~ '}]'
    }
}