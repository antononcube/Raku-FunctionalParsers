use v6.d;

use FunctionalParsers::EBNF::Actions::Common;

class FunctionalParsers::EBNF::Actions::Java::FuncJ
        does FunctionalParsers::EBNF::Actions::Common {

    submethod TWEAK {
        self.ast-head-to-func =
                Sequence => 'and',
                SequencePickLeft => 'andL',
                SequencePickRight => 'andR';
    }

    method setup-code { '
//<dependency>
//    <groupId>org.typemeta</groupId>
//    <artifactId>funcj-parser</artifactId>
//    <version>${funcj.parser.version}</version>
//</dependency>
import funcj.parser;
' }

    has &.terminal = {"string({$_.subst('\'','"'):g})"};

    has &.non-terminal = {"{self.prefix}" ~ self.modifier.($_.subst(/\s/,'').substr(1,*-1))};

    has &.option = {"or($_,any())"};

    has &.repetition = {"many($_)"};

    has &.apply = {"{$_[0]}.map({$_[1].subst(/^ '{'/, '').subst(/'}' $/, '')})"};

    has &.sequence = { $_ ~~ Positional && $_.elems > 1 ?? "({$_.join('.and(')})" !! $_ };

    has &.sequence-pick-left = {
        $_ ~~ Str ?? $_ !! "{self.sequence-pick-left.($_[0])}.andL({$_[1]})"
    };

    has &.sequence-pick-right = {
        $_ ~~ Str ?? $_ !! "({$_[0]}).andR({self.sequence-pick-right.($_[1])})"
    };

    has &.sequence-any = {
        if $_ ~~ Positional && $_.elems > 1 {
            "{$_[1]}.{self.ast-head-to-func{$_[0]}}({self.sequence-any.($_[2])})"
        } else {
            $_
        }
    };

    has &.alternatives = { $_ ~~ Positional && $_.elems > 1 ?? "choice({$_.join(', ')})" !! $_ };

    has &.parens = {$_};

    has &.node = {$_};

    has &.term = { self.sequence.($_) };

    has &.expr = { self.alternatives.($_) };

    has &.rule = { "Parser<Chr, String> {self.non-terminal.($_[0])} = {$_[1]};" };

    has &.grammar = {$_}
}