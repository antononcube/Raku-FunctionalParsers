use v6.d;

unit module FunctionParsers;

#============================================================
# Basic parsers
#============================================================

## Symbol
sub symbol(Str $a) is export(:DEFAULT) {
    -> @x { @x.elems && @x[0] eq $a ?? ((@x.tail(*- 1).List, $a),) !! () }
}

## Token
sub token(Str $k) is export(:DEFAULT) {
    -> @x { @x.elems >= $k.chars && @x[^$k.chars].join eq $k ?? ((@x.tail(*- $k.chars).List, $k),) !! () }
}

## Satisfy
sub satisfy(&pred) is export(:DEFAULT) {
    -> @x { @x.elems && &pred(@x[0]) ?? ((@x.tail(*- 1).List, @x.head),) !! () }
}

## Epsilon
sub epsilon() is export(:DEFAULT) {
    -> @x {((@x, ()),) }
}

## Succeed
proto sub success(|) is export(:DEFAULT) {*}

multi sub success() {
    -> @x { ((@x, ()),) }
}

multi sub success($v){
    -> @x { ((@x, $v),) }
}

## Fail
sub failure is export(:DEFAULT) {
    { () }
}

#============================================================
# Combinators
#============================================================

sub compose-with-results(&p) is export(:DEFAULT) {
    -> @res {
        given @res {
            when $_.elems == 0 { () }
            when $_ ~~ Positional && $_.all ~~ Positional {
                my @flatRes;
                $_.map(-> @r {
                    if @r.elems {
                        my @t = &p(@r[0]);
                        if @t { @flatRes.append( @t.map({ ($_[0], (@r[1], $_[1])) })) }
                    }});
                @flatRes.List
            }
        }
    }
}

## Sequence
proto sub sequence(|) is export(:DEFAULT) {*}

multi sub sequence(&p) { &p }

multi sub sequence(*@args where @args.elems > 1)  {
    -> @x { reduce({ compose-with-results($^b)($^a) }, @args[0](@x), |@args.tail(*-1).List) }
}

# Infix ⨂
sub infix:<«&»>( *@args ) is equiv( &[(&)] ) is export(:double, :ALL) {
    sequence(|@args)
}

sub infix:<(&)>( *@args ) is equiv( &[(&)] ) is export(:set) {
    sequence(|@args)
}

sub infix:<⨂>( *@args ) is equiv( &[(&)] ) is export(:n-ary) {
    sequence(|@args)
}

## Alternatives
sub alternatives(*@args) is export(:DEFAULT) {
    -> @x { my @res; @args.map({ @res.append( $_(@x) ) }); @res.List }
}

# Infix ⨁
sub infix:<«|»>( *@args ) is equiv( &[(|)] ) is export(:double, :ALL) {
    alternatives(|@args)
}

sub infix:<(|)>( *@args ) is equiv( &[(|)] ) is export(:set, :ALL) {
    alternatives(|@args)
}

sub infix:<⨁>( *@args ) is equiv( &[(|)] ) is export(:n-ary, :ALL) {
    alternatives(|@args)
}

#============================================================
# Next combinators
#============================================================

## Space
## (Should we use 'space'?)
sub sp(&p) is export(:DEFAULT) {
    -> @x {
        my $k = 0;
        for @x { last if $_.head.chars && $_.head !~~ / \s+ /; $k++ };
        &p(@x[$k..*-1])
    }
}

## Just
sub just(&p) is export(:DEFAULT) {
    -> @x { my @res = &p(@x); @res.grep({ $_[0].elems == 0 }) }
}

## Some
sub some(&p) is export(:DEFAULT) {
    -> @x { just(&p)(@x).head[1] }
}

## Shortest
sub shortest(&p) is export(:DEFAULT) {
    -> @x { &p(@x).sort({ $_.head.elems })[^1] }
}

## Apply
sub apply(&f, &p) is export(:DEFAULT) {
    -> @x { &p(@x).map({ ($_[0], &f($_[1])) }) }
}

# Infix ⨀
sub infix:<«o>( &p, &f ) is equiv( &[xx] ) is export(:double, :ALL) {
    apply(&f, &p)
}

sub infix:<(^)>( &p, &f ) is equiv( &[xx] ) is export(:set, :ALL) {
    apply(&f, &p)
}

sub infix:<⨀>( &f, &p ) is equiv( &[xx] ) is export(:n-ary, :ALL) {
    apply(&f, &p)
}

## Pick left
sub sequence-pick-left(&p1, &p2) is export(:DEFAULT) {
    apply( {$_[0]}, sequence(&p1, &p2))
}

# Infix ◁
sub infix:<«&>( &p1, &p2 ) is equiv( &[(&)] ) is export(:double, :ALL) {
    sequence-pick-left(&p1, &p2)
}

sub infix:<(\<&)>( &p1, &p2 ) is equiv( &[(&)] ) is export(:set, :ALL) {
    sequence-pick-left(&p1, &p2)
}

sub infix:<◁>( &p1, &p2 ) is equiv( &[(&)] ) is export(:n-ary, :ALL) {
    sequence-pick-left(&p1, &p2)
}

## Pick right
sub sequence-pick-right(&p1, &p2) is export(:DEFAULT) {
    apply( {$_[1]}, sequence(&p1, &p2))
}

# Infix ▷
sub infix:<\&\>>( &p1, &p2 ) is equiv( &[(&)] ) is export(:double, :ALL) {
    sequence-pick-right(&p1, &p2)
}

sub infix:<(&»)>( &p1, &p2 ) is equiv( &[(&)] ) is export(:set, :ALL) {
    sequence-pick-right(&p1, &p2)
}

sub infix:<▷>( &p1, &p2 ) is equiv( &[(&)] ) is export(:n-ary, :ALL) {
    sequence-pick-right(&p1, &p2)
}

#============================================================
# Second next combinators
#============================================================

# Parse pack
sub pack(&s1, &p, &s2) is export(:DEFAULT) {
    # Same as: apply({ $_[0][1]}, sequence(&s1, &p, &s2))
    sequence-pick-left(sequence-pick-right(&s1, &p), &s2)
}

# Parse parenthesized
sub parenthesized(&p) is export(:DEFAULT) {
    pack(symbol('('), &p, symbol(')'))
}

# Parse bracketed
sub bracketed(&p) is export(:DEFAULT) {
    pack(symbol('['), &p, symbol(']'))
}

# Parse curly bracketed
sub curly-bracketed(&p) is export(:DEFAULT) {
    pack(symbol('{'), &p, symbol('}'))
}

# Parse option
sub option(&p) is export(:DEFAULT) {
    alternatives(apply({($_,)}, &p), epsilon)
}

# Parse many
sub many(&p) is export(:DEFAULT) {
    -> @x { alternatives(apply( {($_[0], |$_[1])}, sequence(&p, many(&p))), success())(@x) }
}

# Parse many1
sub many1(&p) is export(:DEFAULT) {
    apply({($_[0], |$_[1])}, sequence(&p, many(&p)))
}

# List of
sub list-of(&p, &sep) is export(:DEFAULT) {
    alternatives(apply({($_[0], |$_[1])}, sequence(&p, many(sequence-pick-right(&sep, &p)))), success())
}

# Chain left
sub chain-left(&p, &sep) is export(:DEFAULT) {
    apply( { reduce( { $^b[0]($^a, $^b[1]) }, $_.head, |$_[1]) }, sequence(&p, just(many(sequence(&sep, &p)))))
}

# Chain right
sub chain-right(&p, &sep) is export(:DEFAULT) {
    apply( { reduce( { $^b[1]($^b[0], $^a) }, $_[1], |$_[0].reverse) }, just(sequence(many(sequence(&p, &sep)), &p)))
}

#============================================================
# Backtracking related
#============================================================

# First
sub take-first(&p) is export(:DEFAULT) {
    -> @x { my $res = &p(@x); ($res.head,) }
}

# Greedy
sub greedy(&p) is export(:DEFAULT) {
    take-first(many(&p))
}

# Greedy1
sub greedy1(&p) is export(:DEFAULT) {
    take-first(many1(&p))
}

# Compulsion
sub compulsion(&p) is export(:DEFAULT) {
    take-first(option(&p))
}

#============================================================
# Self application
#============================================================

sub is-quoted($x) { $x.match(/ ^ [ \' .*? \' |  \" .*? \" ] $ /).Bool };

sub is-ebnf-symbol($x) { $x ∈ ['|', '&', '&>', '<&', ';', ','] };

sub is-non-terminal($x) { $x.match(/ ^ '<' <-[<>]>+ '>' /).Bool }

my &pGTerminal = satisfy({ ($_ ~~ Str) && is-quoted($_) });

my &pGNonTerminal =
        satisfy({
            my $res = ($_ ~~ Str) && is-non-terminal($_) && !is-ebnf-symbol($_);
            $res});

my &pGOption = apply({Pair.new('EBNFOption', $_)}, bracketed(&pGExpr));

my &pGRepetition = apply({Pair.new('EBNFRepetition', $_)}, curly-bracketed(&pGExpr));

my &pGNode = alternatives(
        apply( {Pair.new('EBNFTerminal', $_)}, &pGTerminal),
        apply( {Pair.new('EBNFNonTerminal', $_)}, &pGNonTerminal),
        parenthesized(&pGExpr),
        &pGRepetition,
        &pGOption);

my &seqSepForm = {Pair.new($^a,$^b)};
my &seqSep = alternatives(symbol(','), symbol('<&'), symbol('&>'));

my &pGTerm = alternatives(
        &pGNode,
        apply({ ($_ ~~ Positional && $_.elems > 1) ?? Pair.new('EBNFSequence', $_) !! $_ },
                list-of(&pGNode, &seqSep)
              ));

my &pGExpr = apply({ $_ ~~ Positional && $_.elems > 1 ?? Pair.new('EBNFAlternatives', $_) !! $_ }, list-of(&pGTerm, symbol('|')));

my &pGRule = apply(
        {Pair.new('EBNFRule', $_)},
        sequence(
                sequence-pick-left(&pGNonTerminal, symbol('=')),
                sequence-pick-left(&pGExpr, symbol(';'))));

my &pEBNF = apply({Pair.new('EBNF', $_)}, many(&pGRule));

proto sub parse-ebnf($x) is export {*}

multi sub parse-ebnf(@x) {
    &pEBNF(@x)
}

#============================================================
# Interpretation
#============================================================


#============================================================
# Random sentences
#============================================================
