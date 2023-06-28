use v6.d;

use FunctionalParsers::EBNF::Actions::MermaidJS::Common;
use FunctionalParsers::EBNF::Actions::Raku::AST;

class FunctionalParsers::EBNF::Actions::MermaidJS::Graph
        does FunctionalParsers::EBNF::Actions::MermaidJS::Common
        is FunctionalParsers::EBNF::Actions::Raku::AST {

    has Str $.dir-spec is rw = 'TD';

    multi method is-paired-with(Str $head, $s) {
        return $s ~~ Pair && $s.key eq $head;
    }

    multi method is-paired-with(Regex $rx, $s) {
        return $s ~~ Pair && $s.key ~~ $rx;
    }

    multi method is-paired-with($spec, $s) {
        return False;
    }

    multi method trace($p where self.is-paired-with('EBNFTerminal', $p) ) {
        return self.make-mmd-node($p.value);
    };

    multi method trace($p where self.is-paired-with('EBNFNonTerminal', $p) ) {
        return self.make-mmd-node($p.value);
    };

    multi method trace($p where self.is-paired-with( rx/ '<' <-[<>]>+ '>' /, $p) ) {
        my $res = self.make-mmd-node($p.key);
        self.trace($p.value);
        return $res;
    };

    multi method trace($p where self.is-paired-with('EBNFOption', $p) ) {
        my $op = self.make-mmd-node('opt');
        self.rules.append([ "$op --> {self.trace($p.value)}",]);
        return $op;
    };

    multi method trace($p where self.is-paired-with('EBNFRepetition', $p) ) {
        my $op = self.make-mmd-node('rep');
        self.rules.append([ "$op --> {self.trace($p.value)}",]);
        return $op;
    };

    has &.apply = {"$_[0]"};

    multi method trace($p where self.is-paired-with('EBNFSequence', $p) ) {
        #note 'sequence $_ : ', $_.raku;
        if $p.value ~~ Positional && $p.value.elems > 1 {
            my $op = self.make-mmd-node('seq');
            self.rules.append($p.value.map({ "$op --> {self.trace($_)}" }));
            return $op;
        } else {
            return self.trace($p.value);
        }
    };

    has &.sequence-pick-left = {
        $_ ~~ Str ?? $_ !! "{self.sequence-pick-left.($_[0])} {$_[1].subst(/ ^ '<'/, '<.')}"
    };

    has &.sequence-pick-right = {
        $_ ~~ Str ?? $_ !! "{$_[0].subst(/ ^ '<'/, '<.')} {self.sequence-pick-right.($_[1])}"
    };

    multi method trace($p where self.is-paired-with('EBNFAlternatives', $p) ) {
        #note 'alternatices $_ : ', $_.raku;
        if $p.value ~~ Positional && $p.value.elems > 1 {
            my $op = self.make-mmd-node('alt');
            self.rules.append($p.value.map({ "$op --> {self.trace($_)}" }));
            return $op;
        } else {
            return self.trace($p.value);
        }
    };

    has &.parens = {$_};

    has &.node = {$_};

    has &.term = { self.alternatives.($_) };

    has &.expr = { self.alternatives.($_) };

    multi method trace($p where self.is-paired-with('EBNFRule', $p) ) {
        my $res = self.make-mmd-node($p.value.key);
        self.rules.append(["$res --> {self.trace($p.value.value)}", ]);
        return $res;
    };

    multi method trace($p where self.is-paired-with('EBNF', $p)) {
        my @res = $p.value.map({ self.trace($_) });
        my $code = "graph {self.dir-spec}\n\t";
        $code ~= self.nodes.map({ $_.key ~ $_.value }).join("\n\t");
        $code ~= "\n\t";
        $code ~= self.rules.unique.join("\n\t");

        return $code;
    }

    submethod TWEAK {
        self.grammar = { my $res = Pair.new('EBNF', $_); self.trace($res) }
    }
}