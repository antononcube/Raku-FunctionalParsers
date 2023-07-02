use v6.d;


role FunctionalParsers::EBNF::Actions::MermaidJS::ASTTracer {

    has Str $.dir-spec is rw = 'TD';

    method edge-spec(Str $start, Str $end, Str $tag = '', Str :$con = '-->') {
        $tag ?? "$start $con |$tag|$end" !! "$start $con $end";
    }

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
        self.rules.append([self.edge-spec($op, self.trace($p.value)),]);
        return $op;
    };

    multi method trace($p where self.is-paired-with('EBNFRepetition', $p) ) {
        my $op = self.make-mmd-node('rep');
        self.rules.append([self.edge-spec($op, self.trace($p.value)),]);
        return $op;
    };

    multi method trace($p where self.is-paired-with('EBNFApply', $p) ) {
        my $op = self.make-mmd-node('apply');
        self.rules.append([self.edge-spec($op, "{$op}FUNC[[\"{$p.value.[0]}\"]]"),
                           self.edge-spec($op, self.trace($p.value[1]))]);
        return $op;
    };

    multi method trace($p where self.is-paired-with('EBNFSequence', $p) ) {
        if $p.value ~~ Positional && $p.value.elems > 1 {
            my $op = self.make-mmd-node('seq');
            self.rules.append($p.value.map({ self.edge-spec($op, self.trace($_)) }));
            return $op;
        } else {
            return self.trace($p.value);
        }
    };

    multi method trace($p where self.is-paired-with('EBNFSequencePickLeft', $p) ) {
        if $p.value ~~ Positional && $p.value.elems > 1 {
            my $op = self.make-mmd-node('seqL');

            my $pick = do if $p.value.head ~~ Positional {
                self.edge-spec($op, self.trace(Pair.new('EBNFSequencePickLeft', $p.value.head)), 'L')
            } else {
                self.edge-spec($op, self.trace($p.value.head), 'L')
            }

            self.rules.append([
                $pick,
                self.edge-spec($op, self.trace($p.value[1]), 'R', con => '-.->')
            ]);

            return $op;
        } else {
            return self.trace($p.value);
        }
    };

    multi method trace($p where self.is-paired-with('EBNFSequencePickRight', $p) ) {
        if $p.value ~~ Positional && $p.value.elems > 1 {
            my $op = self.make-mmd-node('seqR');

            my $pick = do if $p.value[1] ~~ Positional {
                self.edge-spec($op, self.trace(Pair.new('EBNFSequencePickRight', $p.value[1])), 'R')
            } else {
                self.edge-spec($op, self.trace($p.value[1]), 'R')
            }

            self.rules.append([
                $pick,
                self.edge-spec($op, self.trace($p.value[0]), 'L', con => '-.->')
            ]);

            return $op;
        } else {
            return self.trace($p.value);
        }
    };

    multi method trace($p where self.is-paired-with('EBNFAlternatives', $p) ) {
        if $p.value ~~ Positional && $p.value.elems > 1 {
            my $op = self.make-mmd-node('alt');
            self.rules.append($p.value.map({ self.edge-spec($op, self.trace($_)) }));
            return $op;
        } else {
            return self.trace($p.value);
        }
    };

    multi method trace($p where self.is-paired-with('EBNFRule', $p) ) {
        my $res = self.make-mmd-node($p.value.key);
        self.rules.append([self.edge-spec($res, self.trace($p.value.value)), ]);
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
}