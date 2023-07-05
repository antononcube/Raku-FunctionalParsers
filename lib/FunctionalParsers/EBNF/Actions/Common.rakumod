use v6.d;

role FunctionalParsers::EBNF::Actions::Common {
    has Str $.name is rw = 'FP';
    has Str $.prefix is rw  = 'p';
    has Str $.start is rw = 'top';
    has &.modifier is rw = {$_.uc};
    has &.id-normalizer is rw = {$_.subst(/ \s /, '_', :g).subst(/^ '<' | '>' $ /, '', :g)};

    has %.ast-head-to-func is rw =
            Sequence => 'sequence',
            SequencePickLeft => 'sequence-pick-left',
            SequencePickRight => 'sequence-pick-right';

    method top-rule-name { self.prefix ~ self.modifier.(self.start) }
    method setup-code { 'use FunctionalParsers;' }

    method to-quoted($s) {
        given $s {
            when $_ ~~ / ^ \" .* \" $ | ^ \' .+ \' $ / { $s }
            default { "\"$s\"" }
        }
    }

    method to-double-quoted($s) {
        given $s {
            when $_ ~~ / ^ \" .* \" $ / { $s }
            when $_ ~~ / ^ \' .+ \' $ / { "\"{ $s.substr(1, *- 1) }\"" }
            default { "\"$s\"" }
        }
    }

    method to-single-quoted($s) {
        given $s {
            when $_ ~~ / ^ \' .* \' $ / { $s }
            when $_ ~~ / ^ \" .+ \" $ / { "\"{ $s.substr(1, *- 1) }\"" }
            default { "'$s'" }
        }
    }

    method to-angle-bracketed($s) { $s ~~ / ^ '<' .* '>' $ / ?? $s !! "<$s>" }

    multi method reallyflat (+@list) { gather @list.deepmap: *.take }

    method flatten-sequence($x) {
        if $x ~~ Pair && $x.key.starts-with('EBNFSequence') {
            return self.flatten-sequence($x.value[1]).prepend($x.value[0]);
        } else {
            return [$x,];
        }
    }
}