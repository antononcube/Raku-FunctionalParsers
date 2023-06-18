use v6.d;
# This class can be implemented by inheriting
#   FunctionalParsers::EBNF::Actions::Code
# or
#   FunctionalParsers::EBNF::Actions::ClassAttr
# But it seems simpler to just put all definitions here.
# (Since they are concise.)

class FunctionalParsers::EBNF::Actions::Raku::Grammar {
    has Str $.name = 'FP';
    has Str $.prefix = 'p';
    has Str $.start is rw = 'top';

    has &.terminal = {"$_"};

    has &.non-terminal = { "$_"};

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
        my $code = "grammar {self.name} \{\n\t";
        $code ~= $_.List.join("\n\t");
        $code ~= "\n}";
        $code;
    }
}