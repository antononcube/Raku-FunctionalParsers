use v6.d;

use FunctionalParsers::EBNF::Actions::Common;

class FunctionalParsers::EBNF::Actions::Raku::Random
        is FunctionalParsers::EBNF::Actions::Common {

    has UInt $.max-repetitions = 4;
    has UInt $.min-repetitions = 0;
    has Bool $.restrict-recursion = True;

    has &.terminal = {"$_"};

    has &.non-terminal = {"self.{self.prefix}" ~ $_.uc.subst(/\s/,'').subst(/^ '<'/,'').subst(/'>' $/,'') };

    has &.option = { "(rand > 0.5 ?? $_ !! Empty)" };

    has &.repetition = {"$_ xx (({self.min-repetitions}..{self.max-repetitions}).pick)"};

    #has &.apply = {"apply(&{$_[1]}, {$_[0]})"};
    has &.apply = {$_[0]};

    has &.sequence = { $_ ~~ Positional && $_.elems > 1 ?? "({$_.join(', ')})" !! "$_" };

    has &.sequence-pick-left = { self.sequence.(self.reallyflat($_).List)  };

    has &.sequence-pick-right = { self.sequence.(self.reallyflat($_).List) };

    method flat-any-sequence($spec --> Array) {
        return do if $spec ~~ Iterable && $spec.elems > 1 {
            [$spec[1], |self.flat-any-sequence($spec[2])]
        } elsif $spec ~~ Str {
            [$spec,]
        } else {
            []
        }
    }

    has &.sequence-any = {
        my @res = self.flat-any-sequence($_).flat; self.sequence.(@res)
    };

    has &.alternatives = { $_ ~~ Positional && $_.elems > 1 ?? "({$_.join(', ')}).pick" !! "$_" };

    has &.parens = {$_};

    has &.node = {$_};

    has &.term = { self.sequence-any.($_) };

    has &.expr = { self.alternatives.($_) };

    has &.rule = {
        my $mname = self.non-terminal.($_[0]).subst(/ ^ 'self.' /, '').subst(/ '($_)}' $/, '');
        if $!restrict-recursion {
            "method { $mname } \{ \$visits.add('{ $mname }'); if \$visits<{ $mname }> ≤ \$maxReps \{ { $_[1] } \} else \{ Empty \}\}"
        } else {
            "method {$mname} \{ {$_[1]} \}"
        }
    };

    has &.grammar = {
        my $code = "class {self.name} \{\n\t";
        if $!restrict-recursion {
            $code ~= "my BagHash \$visits;\n\t";
            $code ~= "my UInt \$maxReps = { $!max-repetitions };\n\t";
        }
        $code ~= $_.List.join("\n\t");
        if $!restrict-recursion {
            $code ~= "\n\thas \&.parser is rw = \{ \$visits .= new; self.{ self.top-rule-name } \};";
        } else {
            $code ~= "\n\thas \&.parser is rw = \{ self.{ self.top-rule-name } \};";
        }
        $code ~= "\n}";
        $code;
    }
}