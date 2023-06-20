use v6.d;

use FunctionalParsers::EBNF::Actions::Common;

class FunctionalParsers::EBNF::Actions::Java::Code
        does FunctionalParsers::EBNF::Actions::Common {

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

    has &.alternatives = { $_ ~~ Positional && $_.elems > 1 ?? "choice({$_.join(', ')})" !! $_ };

    has &.parens = {$_};

    has &.node = {$_};

    has &.term = { self.sequence.($_) };

    has &.expr = { self.alternatives.($_) };

    has &.rule = { "Parser<Chr, String> {self.non-terminal.($_[0])} = {$_[1]};" };

    has &.grammar = {$_}
}