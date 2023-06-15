use v6.d;
# This class can be implemented by inheriting
#   FunctionalParsers::EBNF::Actions::Code
# or
#   FunctionalParsers::EBNF::Actions::ClassAttr
# But it seems simpler to just put all definitions here.
# (Since they are concise.)

class FunctionalParsers::EBNF::Actions::Raku::Class {
    has Str $.name = 'FP';
    has Str $.prefix = 'p';

    has &.terminal = {"symbol($_)"};

    has &.non-terminal = {'{' ~ "self.{self.prefix}" ~ $_.uc.subst(/\s/,'').substr(1,*-1) ~ '($_)}'};

    has &.option = {"option($_)"};

    has &.repetition = {"many($_)"};

    has &.apply = {"apply(&{$_[1]}, {$_[0]})"};

    has &.sequence = { $_ ~~ Positional && $_.elems > 1 ?? "sequence({$_.join(', ')})" !! $_ };

    has &.alternatives = { $_ ~~ Positional && $_.elems > 1 ?? "alternatives({$_.join(', ')})" !! $_ };

    has &.parens = {$_};

    has &.node = {$_};

    has &.term = { self.sequence.($_) };

    has &.expr = { self.alternatives.($_) };

    has &.rule = {
        my $mname = self.non-terminal.($_[0]).subst(/ ^ '{self.' /, '').subst(/ '($_)}' $/, '');
        "method {$mname}(@x) \{ {$_[1]}(@x) \}"
    };

    has &.grammar = {
        my $code = "class {self.name} \{\n\t";
        $code ~= $_.List.join("\n\t");
        $code ~= "\n\thas \&.parser is rw = ->@x \{ self.pTOP(@x) \};";
        $code ~= "\n}";
        $code;
    }
}