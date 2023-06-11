use v6.d;

use FunctionalParsers::Actions::Raku::EBNFParserClass;
use FunctionalParsers::Actions::Raku::EBNFParserCode;
use FunctionalParsers::Actions::Raku::EBNFParserPairs;
#use FunctionalParsers::Actions::Raku::EBNFParserRandom;
use FunctionalParsers::Actions::WL::EBNFParserCode;

unit module FunctionParsers;

#============================================================
# Basic parsers
#============================================================

## Symbol
sub symbol(Str $a) is export(:DEFAULT, :ALL) {
    -> @x { @x.elems && @x[0] eq $a ?? ((@x.tail(*- 1).List, $a),) !! () }
}

## Token
sub token(Str $k) is export(:DEFAULT, :ALL) {
    -> @x { @x.elems >= $k.chars && @x[^$k.chars].join eq $k ?? ((@x.tail(*- $k.chars).List, $k),) !! () }
}

## Satisfy
sub satisfy(&pred) is export(:DEFAULT, :ALL) {
    -> @x { @x.elems && &pred(@x[0]) ?? ((@x.tail(*- 1).List, @x.head),) !! () }
}

## Epsilon
sub epsilon() is export(:DEFAULT, :ALL) {
    -> @x {((@x, ()),) }
}

## Succeed
proto sub success(|) is export(:DEFAULT, :ALL) {*}

multi sub success() {
    -> @x { ((@x, ()),) }
}

multi sub success($v){
    -> @x { ((@x, $v),) }
}

## Fail
sub failure is export(:DEFAULT, :ALL) {
    { () }
}

#============================================================
# Combinators
#============================================================

sub compose-with-results(&p, @res) is export(:DEFAULT, :ALL) {
    return do given @res {
        when $_.elems == 0 { () }
        when $_ ~~ Positional && $_.all ~~ Positional {
            my @flatRes;
            $_.map(-> @r {
                if @r ~~ List && @r.elems == 2 {
                    my @t = &p(@r[0]);
                    @t = @t.grep({ $_.elems });
                    if @t {
                        @flatRes.append( @t.map({ ($_[0], (@r[1], $_[1])) }))
                    }
                }});
            @flatRes.List
        }
        default {
            # Is there something better to do here?
            note "Unhandled case in compose-with-results: {@res.gist} : {&p.gist}";
            ()
        }
    }
}

## Sequence
proto sub sequence(|) is export(:DEFAULT, :ALL) {*}

multi sub sequence(&p) { &p }

# Original
multi sub sequence(*@args where @args.elems > 1 && @args.all ~~ Callable )  {
    -> @x { reduce({ compose-with-results($^b, $^a) }, @args[0](@x), |@args.tail(*-1).List) }
}

# Is this easier to maintain or debug with?
# Fails faster?
#multi sub sequence(*@args where @args.elems > 1 && @args.all ~~ Callable )  {
#    -> @x {
#        my @res = @args[0](@x);
#        for @args.tail(*-1) -> &p {
#            last if !(@res ~~ Iterable && @res.elems);
#            @res = compose-with-results(&p, @res);
#        }
#        (@res ~~ Iterable && @res.elems) ?? @res !! ();
#    }
#}

# This might be useful re-writing.
#`[
multi sub sequence(&p1, &p2) {
    -> @x {
        my @res1 = &p1(@x);
        @res1.map( -> @r {
            my @res2 = &p2($_.head);
            if @res2 {
                @res2.map({ ($_[0], (@r[1], $_[1])) })
            } else {
                Empty
            }
        });
    }
}

multi sub sequence(*@args where @args.elems > 1 && @args.all ~~ Callable )  {
    -> @x { reduce( sequence($^a, $^b), @args) } # Not complete
}
]

# Infix ⨂
sub infix:<«&»>( *@args ) is equiv( &infix:<&&> ) is assoc<list> is export(:double, :ALL) {
    sequence(|@args)
}

sub infix:<(&)>( *@args ) is equiv( &infix:<&&> ) is assoc<list> is export(:set) {
    sequence(|@args)
}

sub infix:<⨂>( *@args ) is equiv( &infix:<&&> ) is assoc<list> is export(:n-ary) {
    sequence(|@args)
}

## Alternatives
sub alternatives(*@args) is export(:DEFAULT, :ALL) {
    -> @x { my @res; @args.map({ @res.append( $_(@x) ) }); @res.List }
}

# Infix ⨁
sub infix:<«|»>( *@args ) is equiv( &infix:<||> ) is assoc<list> is export(:double, :ALL) {
    alternatives(|@args)
}

sub infix:<(|)>( *@args ) is equiv( &infix:<||> ) is assoc<list> is export(:set, :ALL) {
    alternatives(|@args)
}

sub infix:<⨁>( *@args ) is equiv( &infix:<||> ) is assoc<list> is export(:n-ary, :ALL) {
    alternatives(|@args)
}

#============================================================
# Next combinators
#============================================================

## Space
## (See the shortcuts below -- sp can be used instead.)
sub drop-spaces(&p) is export(:DEFAULT, :ALL) {
    -> @x {
        my $k = 0;
        for @x { last if $_.head.chars && $_.head !~~ / \s+ /; $k++ };
        &p(@x[$k..*-1])
    }
}

## Just
sub just(&p) is export(:DEFAULT, :ALL) {
    -> @x { my @res = &p(@x); @res.grep({ $_[0].elems == 0 }) }
}

## Some
sub some(&p) is export(:DEFAULT, :ALL) {
    -> @x { just(&p)(@x).head[1] }
}

## Shortest
sub shortest(&p) is export(:DEFAULT, :ALL) {
    -> @x { &p(@x).sort({ $_.head.elems })[^1] }
}

## Apply
sub apply(&f, &p) is export(:DEFAULT, :ALL) {
    -> @x { &p(@x).map({ ($_[0], &f($_[1])) }) }
}

# Infix ⨀
sub infix:<«o>( &p, &f ) is equiv( &[*] ) is assoc<left> is export(:double, :ALL) {
    apply(&f, &p)
}

sub infix:<(^)>( &p, &f ) is equiv( &[*] ) is assoc<left> is export(:set, :ALL) {
    apply(&f, &p)
}

sub infix:<⨀>( &f, &p ) is equiv( &[*] ) is assoc<right> is export(:n-ary, :ALL) {
    apply(&f, &p)
}

## Pick left
sub sequence-pick-left(&p1, &p2) is export(:DEFAULT, :ALL) {
    apply( {$_[0]}, sequence(&p1, &p2))
}

# Infix ◁
sub infix:<«&>( &p1, &p2 ) is equiv( &[**] ) is assoc<left> is export(:double, :ALL) {
    sequence-pick-left(&p1, &p2)
}

sub infix:<(\<&)>( &p1, &p2 ) is equiv( &[**] ) is assoc<left> is export(:set, :ALL) {
    sequence-pick-left(&p1, &p2)
}

sub infix:<◁>( &p1, &p2 ) is equiv( &[**] ) is assoc<left> is export(:n-ary, :ALL) {
    sequence-pick-left(&p1, &p2)
}

## Pick right
sub sequence-pick-right(&p1, &p2) is export(:DEFAULT, :ALL) {
    apply( {$_[1]}, sequence(&p1, &p2))
}

# Infix ▷
sub infix:<\&\>>( &p1, &p2 ) is equiv( &[**] ) is assoc<right> is export(:double, :ALL) {
    sequence-pick-right(&p1, &p2)
}

sub infix:<(&»)>( &p1, &p2 ) is equiv( &[**] ) is assoc<right> is export(:set, :ALL) {
    sequence-pick-right(&p1, &p2)
}

sub infix:<▷>( &p1, &p2 ) is equiv( &[**] ) is assoc<right> is export(:n-ary, :ALL) {
    sequence-pick-right(&p1, &p2)
}

#============================================================
# Second next combinators
#============================================================

# Parse pack
sub pack(&s1, &p, &s2) is export(:DEFAULT, :ALL) {
    # Same as: apply({ $_[0][1]}, sequence(&s1, &p, &s2))
    sequence-pick-left(sequence-pick-right(&s1, &p), &s2)
}

# Parse parenthesized
sub parenthesized(&p) is export(:DEFAULT, :ALL) {
    pack(symbol('('), &p, symbol(')'))
}

# Parse bracketed
sub bracketed(&p) is export(:DEFAULT, :ALL) {
    pack(symbol('['), &p, symbol(']'))
}

# Parse curly bracketed
sub curly-bracketed(&p) is export(:DEFAULT, :ALL) {
    pack(symbol('{'), &p, symbol('}'))
}

# Parse option
sub option(&p) is export(:DEFAULT, :ALL) {
    alternatives(apply({($_,)}, &p), epsilon)
}

# Parse many
sub many(&p) is export(:DEFAULT, :ALL) {
    -> @x { alternatives(apply( {($_[0], |$_[1])}, sequence(&p, many(&p))), success())(@x) }
}

# Parse many1
sub many1(&p) is export(:DEFAULT, :ALL) {
    apply({($_[0], |$_[1])}, sequence(&p, many(&p)))
}

# List of
sub list-of(&p, &sep) is export(:DEFAULT, :ALL) {
    alternatives(apply({($_[0], |$_[1])}, sequence(&p, many(sequence-pick-right(&sep, &p)))), success())
}

# Chain left
sub chain-left(&p, &sep) is export(:DEFAULT, :ALL) {
    apply( { reduce( { $^b[0]($^a, $^b[1]) }, $_.head, |$_[1]) }, sequence(&p, just(many(sequence(&sep, &p)))))
}

# Chain right
sub chain-right(&p, &sep) is export(:DEFAULT, :ALL) {
    apply( { reduce( { $^b[1]($^b[0], $^a) }, $_[1], |$_[0].reverse) }, just(sequence(many(sequence(&p, &sep)), &p)))
}

#============================================================
# Backtracking related
#============================================================

# First
sub take-first(&p) is export(:DEFAULT, :ALL) {
    -> @x { my $res = &p(@x); ($res.head,) }
}

# Greedy
sub greedy(&p) is export(:DEFAULT, :ALL) {
    take-first(many(&p))
}

# Greedy1
sub greedy1(&p) is export(:DEFAULT, :ALL) {
    take-first(many1(&p))
}

# Compulsion
sub compulsion(&p) is export(:DEFAULT, :ALL) {
    take-first(option(&p))
}

#============================================================
# Shortcuts
#============================================================

sub sp(&p) is export(:shortcuts, :ALL) { drop-spaces(&p) }

proto seq(|) is export(:shortcuts, :ALL) {*}
multi sub seq(&p) { sequence(&p) }
multi sub seq(*@args where @args.elems > 1) { sequence(@args) }

sub seql(&p1, &p2) is export(:shortcuts, :ALL) { sequence-pick-left(&p1, &p2) }

sub seqr(&p1, &p2) is export(:shortcuts, :ALL) { sequence-pick-right(&p1, &p2) }

sub alt(*@args) is export(:shortcuts, :ALL) { alternatives(@args) }

#============================================================
# Self application
#============================================================

our $ebnfActions = FunctionalParsers::Actions::Raku::EBNFParserPairs.new;

sub is-quoted($x) { $x.match(/ ^ [ \' .*? \' |  \" .*? \" ] $ /).Bool };

sub is-ebnf-symbol($x) { $x ∈ ['|', '&', '&>', '<&', ';', ','] };

sub is-non-terminal($x) { $x.match(/ ^ '<' <-[<>]>+ '>' /).Bool }

sub pGTerminal(@x) {
    satisfy({ ($_ ~~ Str) && is-quoted($_) })(@x)
}

sub pGNonTerminal(@x) {
        satisfy({
            my $res = ($_ ~~ Str) && is-non-terminal($_) && !is-ebnf-symbol($_);
            $res})(@x)
}

sub pGOption(@x) {
    apply($ebnfActions.option, bracketed(&pGExpr))(@x)
}

sub pGRepetition(@x) {
    apply($ebnfActions.repetition, curly-bracketed(&pGExpr))(@x)
}

sub pGParens(@x) {
    parenthesized(&pGExpr)(@x)
}

sub pGNode(@x) { alternatives(
        apply($ebnfActions.terminal, &pGTerminal),
        apply($ebnfActions.non-terminal, &pGNonTerminal),
        &pGParens,
        &pGRepetition,
        &pGOption)(@x)
}

my &seqSepForm = {Pair.new($^a,$^b)};
my &seqSep = alternatives(symbol(','), symbol('<&'), symbol('&>'));

sub pGTerm(@x) {
    apply($ebnfActions.term, list-of(&pGNode, &seqSep))(@x)
}

sub pGExpr(@x) {
    apply($ebnfActions.alternatives, list-of(&pGTerm, symbol('|')))(@x)
}

sub pGRule(@x) {
    apply($ebnfActions.rule,
        sequence(
                sequence-pick-left(&pGNonTerminal, symbol('=')),
                sequence-pick-left(&pGExpr, symbol(';'))))(@x);
}

sub pEBNF(@x) {
    apply($ebnfActions.grammar, shortest(many(&pGRule)))(@x)
}


#============================================================
# Interpretation
#============================================================
proto sub parse-ebnf($x,|) is export(:DEFAULT, :ALL) {*}

multi sub parse-ebnf(@x,
                     :$actions = Whatever,
                     :$name is copy = Whatever,
                     :$parser-prefix is copy = Whatever,
                     :to(:$to-lang) is copy = Whatever,
                     Bool :$eval = True) {

    # Process parser-prefix
    if $parser-prefix.isa(Whatever) { $parser-prefix = 'p'; }
    die 'The argument $parser-prefix is expected to be a string or Whatever.'
    unless $parser-prefix ~~ Str;

    # Process target
    if $to-lang.isa(Whatever) { $to-lang = 'Raku'; }
    die 'The argument $to-lang is expected to be a Whatever or one of <Raku WL>.'
    unless $to-lang ~~ Str && $to-lang ∈ <Raku WL>;

    given $actions {
        when Whatever {
            $ebnfActions = FunctionalParsers::Actions::Raku::EBNFParserPairs.new;
            return pEBNF(@x).List;
        }

        when $_ ∈ <code parser-code> {
            $ebnfActions = ::("FunctionalParsers::Actions::{$to-lang}::EBNFParserCode").new;
            return pEBNF(@x);
        }

        when $_ ∈ <class parser-class> {

            # React to $to-lang if needed
            if $to-lang ne 'Raku' {
                warn "The value of $to-lang is expected to be 'Raku' when \$actions is '$actions'.";
            }

            # Process name
            if $name.isa(Whatever) { $name = 'FP'; }
            die "The argument \$name is expected to be a string or Whatever."
            unless $name ~~ Str;

            # Make parser generator
            $ebnfActions = FunctionalParsers::Actions::Raku::EBNFParserClass.new(:$name, prefix => $parser-prefix);

            # Generate code of parser class
            my $res = pEBNF(@x).List;

            # Evaluate the class
            if $eval {
                use MONKEY-SEE-NO-EVAL;
                $res = EVAL $res.head.tail;
            }

            # Result
            return $res;
        }

        default {
            die 'Do not know how interpret the value of the argument $actions.';
        }
    }
}


#============================================================
# Random sentences
#============================================================
#proto random-sentences($ebnf, |) is export(:DEFAULT, :ALL) {*}
#
#multi sub random-sentences($ebnf, UInt $n = 1) {
#    $ebnfActions = FunctionalParsers::Actions::Raku::EBNFParserRandom.new;
#    my @tokens = $ebnf.split(/ \s /, :skip-empty);
#    return (^$n).map({ pEBNF(@tokens).head.tail });
#}
