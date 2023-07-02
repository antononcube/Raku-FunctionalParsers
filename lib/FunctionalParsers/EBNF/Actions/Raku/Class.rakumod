use v6.d;
# This class can be implemented by inheriting
#   FunctionalParsers::EBNF::Actions::Code
# or
#   FunctionalParsers::EBNF::Actions::ClassAttr
# But it seems simpler to just put all definitions here.
# (Since they are concise.)

use FunctionalParsers::EBNF::Actions::Common;

class FunctionalParsers::EBNF::Actions::Raku::Class
        is FunctionalParsers::EBNF::Actions::Common {

    has &.terminal = {"symbol($_)"};

    has &.non-terminal = {'{' ~ "self.{self.prefix}" ~ self.modifier.($_.subst(/\s/,'').subst(/^ '<'/,'').subst(/'>' $/,'')) ~ '($_)}'};

    has &.option = {"option($_)"};

    has &.repetition = {"many($_)"};

    has &.apply = {"apply(&{$_[1]}, {$_[0]})"};

    has &.sequence = { $_ ~~ Positional && $_.elems > 1 ?? "sequence({$_.join(', ')})" !! $_ };

    has &.sequence-pick-left = {
        $_ ~~ Str ?? $_ !! "sequence-pick-left({self.sequence-pick-left.($_[0])}, {$_[1]})"
    };

    has &.sequence-pick-right = {
        $_ ~~ Str ?? $_ !! "sequence-pick-right({$_[0]}, {self.sequence-pick-right.($_[1])})"
    };

    has &.sequence-any = {
        if $_ ~~ Positional && $_.elems > 1 {
            "{self.ast-head-to-func{$_[0]}}({$_[1]}, {self.sequence-any.($_[2])})"
        } else {
            $_
        }
    };

    has &.alternatives = { $_ ~~ Positional && $_.elems > 1 ?? "alternatives({$_.join(', ')})" !! $_ };

    has &.parens = {$_};

    has &.node = {$_};

    has &.term = { self.sequence-any.($_) };

    has &.expr = { self.alternatives.($_) };

    has &.rule = {
        my $mname = self.non-terminal.($_[0]).subst(/ ^ '{self.' /, '').subst(/ '($_)}' $/, '');
        "method {$mname}(@x) \{ {$_[1]}(@x) \}"
    };

    has &.grammar = {
        my $code = "class {self.name} \{\n\t";
        $code ~= $_.List.join("\n\t");
        $code ~= "\n\thas \&.parser is rw = -> @x \{ self.{ self.top-rule-name}(@x) \};";
        $code ~= "\n}";
        $code;
    }
}