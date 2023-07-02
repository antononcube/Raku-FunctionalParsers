use v6.d;

use FunctionalParsers::EBNF::Actions::Common;

class FunctionalParsers::EBNF::Actions::WL::Code
        does FunctionalParsers::EBNF::Actions::Common {

    submethod TWEAK {
        self.ast-head-to-func =
                Sequence => 'ParseSequentialComposition',
                SequencePickLeft => 'ParseSequentialCompositionPickLeft',
                SequencePickRight => 'ParseSequentialCompositionPickRight';
    }

    method setup-code { 'PacletInstall["AntonAntonov/FunctionalParsers"]; Needs["AntonAntonov`FunctionalParsers`"];' }

    has &.terminal = {"ParseSymbol[{$_.subst('\'','"'):g}]"};

    has &.non-terminal = {"{self.prefix}" ~ self.modifier.($_.subst(/\s/,'').substr(1,*-1))};

    has &.option = {"ParseOption[$_]"};

    has &.repetition = {"ParseMany[$_]"};

    has &.apply = {"ParseApply[{$_[1].subst(/^ '{'/, '').subst(/'}' $/, '')}, {$_[0]}]"};

    has &.sequence = { $_ ~~ Positional && $_.elems > 1 ?? "ParseSequentialComposition[{$_.join(', ')}]" !! $_ };

    has &.sequence-pick-left = {
        $_ ~~ Str ?? $_ !! "ParseSequentialCompositionPickLeft[{self.sequence-pick-left.($_[0])}, {$_[1]}]"
    };

    has &.sequence-pick-right = {
        $_ ~~ Str ?? $_ !! "ParseSequentialCompositionPickRight[{$_[0]}, {self.sequence-pick-right.($_[1])}]"
    };

    has &.sequence-any = {
        if $_ ~~ Positional && $_.elems > 1 {
            "{self.ast-head-to-func{$_[0]}}[{$_[1]}, {self.sequence-any.($_[2])}]"
        } else {
            $_
        }
    };

    has &.alternatives = { $_ ~~ Positional && $_.elems > 1 ?? "ParseAlternativeComposition[{$_.join(', ')}]" !! $_ };

    has &.parens = {$_};

    has &.node = {$_};

    has &.term = { self.sequence-any.($_) };

    has &.expr = { self.alternatives.($_) };

    has &.rule = { "{self.non-terminal.($_[0])} = {$_[1]};" };

    has &.grammar = {$_}
}