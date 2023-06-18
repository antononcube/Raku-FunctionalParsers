use v6.d;
# This class can be implemented by inheriting
#   FunctionalParsers::EBNF::Actions::Code
# or
#   FunctionalParsers::EBNF::Actions::ClassAttr
# But it seems simpler to just put all definitions here.
# (Since they are concise.)

use FunctionalParsers::EBNF::Actions::Common;

class FunctionalParsers::EBNF::Actions::Raku::Grammar
        is FunctionalParsers::EBNF::Actions::Common {

    has Str $.type is rw = 'grammar';

    has &.terminal = {"$_"};

    has &.non-terminal = { "<{self.prefix}{self.modifier.($_.substr(1))}"};

    has &.option = {"$_?"};

    has &.repetition = {"$_*"};

    has &.apply = {"$_[0]"};

    has &.sequence = { $_ ~~ Positional && $_.elems > 1 ?? "{$_.join(' ')}" !! $_ };

    has &.sequence-pick-left = {
        $_ ~~ Str ?? $_ !! "{self.sequence-pick-left.($_[0])} {$_[1].subst(/ ^ '<'/, '<.')}"
    };

    has &.sequence-pick-right = {
        $_ ~~ Str ?? $_ !! "{$_[0].subst(/ ^ '<'/, '<.')} {self.sequence-pick-right.($_[1])}"
    };

    has &.alternatives = { $_ ~~ Positional && $_.elems > 1 ?? "{$_.join(' | ')}" !! $_ };

    has &.parens = {$_};

    has &.node = {$_};

    has &.term = { self.alternatives.($_) };

    has &.expr = { self.alternatives.($_) };

    has &.rule = {
        my $mname = self.non-terminal.($_[0]).substr(1, *-1);
        "rule {$mname} \{ {$_[1]} \}"
    };

    has &.grammar = {

        die "The attribute type is expected to be 'grammar' or 'role'."
        unless self.type ∈ <grammar role>;

        my $code = "{self.type} {self.name} \{\n\t";
        $code ~= $_.List.join("\n\t");
        $code ~= "\n}";

        $code.subst(self.topRuleName, 'TOP');
    }
}