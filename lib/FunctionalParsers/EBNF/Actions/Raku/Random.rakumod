use v6.d;

use FunctionalParsers::EBNF::Actions::Common;

class FunctionalParsers::EBNF::Actions::Raku::Random
        is FunctionalParsers::EBNF::Actions::Common {

    has UInt $.max-repetitions = 4;
    has UInt $.min-repetitions = 0;

    has &.terminal = {"$_"};

    has &.non-terminal = {"self.{self.prefix}" ~ $_.uc.subst(/\s/,'').substr(1,*-1)};

    has &.option = { "(rand > 0.5 ?? $_ !! Empty)" };

    has &.repetition = {"$_ xx (({self.min-repetitions}..{self.max-repetitions}).pick)"};

    #has &.apply = {"apply(&{$_[1]}, {$_[0]})"};
    has &.apply = {$_[0]};

    has &.sequence = { $_ ~~ Positional && $_.elems > 1 ?? "({$_.join(', ')})" !! "$_" };

    has &.sequence-pick-left = { self.sequence.($_) };

    has &.sequence-pick-right = { self.sequence.($_) };

    has &.alternatives = { $_ ~~ Positional && $_.elems > 1 ?? "({$_.join(', ')}).pick" !! "$_" };

    has &.parens = {$_};

    has &.node = {$_};

    has &.term = { self.alternatives.($_) };

    has &.expr = { self.alternatives.($_) };

    has &.rule = {
        my $mname = self.non-terminal.($_[0]).subst(/ ^ 'self.' /, '').subst(/ '($_)}' $/, '');
        "method {$mname} \{ {$_[1]} \}"
    };

    has &.grammar = {
        my $code = "class {self.name} \{\n\t";
        $code ~= $_.List.join("\n\t");
        $code ~= "\n\thas \&.parser is rw = \{ self.{self.top-rule-name} \};";
        $code ~= "\n}";
        $code;
    }
}