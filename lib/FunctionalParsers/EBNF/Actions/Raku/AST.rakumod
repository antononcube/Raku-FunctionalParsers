use v6.d;

use FunctionalParsers::EBNF::Actions::Common;

class FunctionalParsers::EBNF::Actions::Raku::AST
        does FunctionalParsers::EBNF::Actions::Common {

    has Bool $.normalize = True;

    has &.terminal = {Pair.new('EBNFTerminal', $!normalize ?? self.to-double-quoted($_) !! $_) };

    has &.non-terminal = {Pair.new('EBNFNonTerminal', $!normalize ?? self.to-angle-bracketed($_) !! $_)};

    has &.option = {Pair.new('EBNFOption', $_)};

    has &.repetition = {Pair.new('EBNFRepetition', $_)};

    has &.apply = {Pair.new('EBNFApply', ($_[1], $_[0]))};

    has &.sequence = {$_ ~~ Positional && $_.elems > 1 ?? Pair.new('EBNFSequence', $_) !! $_.head};

    has &.sequence-pick-left = {$_ ~~ Positional && $_.elems > 1 ?? Pair.new('EBNFSequencePickLeft', $_) !! $_.head};

    has &.sequence-pick-right = {$_ ~~ Positional && $_.elems > 1 ?? Pair.new('EBNFSequencePickRight', $_) !! $_.head};

    has &.sequence-any = {
        if $_ ~~ Positional && $_.elems > 1 {
            Pair.new("EBNF" ~ $_[0], ($_[1], self.sequence-any.($_[2])))
        } else {
            $_
        }
    };

    has &.alternatives = {$_ ~~ Positional && $_.elems > 1 ?? Pair.new('EBNFAlternatives', $_) !! $_.head};

    has &.parens = {$_};

    has &.node = {$_};

    has &.term = {
        my $res = self.sequence-any.($_);
        if $res.Str.contains('EBNFSequencePickLeft') || $res.Str.contains('EBNFSequencePickRight') {
            $res;
        } else {
            my @res = self.flatten-sequence($res);
            @res.elems > 1 ?? Pair.new('EBNFSequence', @res.List) !! @res.head
        }
    };

    has &.expr = { self.alternatives.($_) };

    has &.rule = {Pair.new('EBNFRule', Pair.new($!normalize ?? self.to-angle-bracketed($_[0]) !! $_[0], $_[1]))};

    has &.grammar is rw = {Pair.new('EBNF', $_)}
}