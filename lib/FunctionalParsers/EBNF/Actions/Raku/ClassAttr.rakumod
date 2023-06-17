use v6.d;

# This class can be implemented by inheriting
#   FunctionalParsers::EBNF::Actions::Code
# But it seems simpler to just put all definitions here.
# (Since they are concise.)

class FunctionalParsers::EBNF::Actions::Raku::ClassAttr {
    has Str $.name = 'FP';
    has Str $.prefix is rw = 'p';

    has &.terminal = {"symbol($_)"};

    has &.non-terminal = {"self.{self.prefix}" ~ $_.uc.subst(/\s/,'').substr(1,*-1)};

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

    has &.alternatives = { $_ ~~ Positional && $_.elems > 1 ?? "alternatives({$_.join(', ')})" !! $_ };

    has &.parens = {$_};

    has &.node = {$_};

    has &.term = { self.alternatives.($_) };

    has &.expr = { self.alternatives.($_) };

    has &.rule = { "has {self.non-terminal.($_[0]).subst(/ ^ 'self.'/, '&.')} is rw = {$_[1]};" };

    has &.grammar = {
        my $code = "class {self.name} \{\n\t";
        $code ~= $_.join("\n\t");
        $code ~= "\n\tmethod parse(@x) \{ self.pTOP.(@x) \}";
        $code ~= "\n}";
        $code;
    }
}