use v6.d;

unit module FunctionalParsers;

#============================================================
# Basic parsers
#============================================================

## Symbol
sub symbol(Str $a) is export(:MANDATORY, :ALL) {
    -> @x { @x.elems && @x[0] eq $a ?? ((@x.tail(*- 1).List, $a),) !! () }
}

## Token
sub token(Str $k) is export(:MANDATORY, :ALL) {
    -> @x { @x.elems >= $k.chars && @x[^$k.chars].join eq $k ?? ((@x.tail(*- $k.chars).List, $k),) !! () }
}

## Satisfy
sub satisfy(&pred) is export(:MANDATORY, :ALL) {
    -> @x { @x.elems && &pred(@x[0]) ?? ((@x.tail(*- 1).List, @x.head),) !! () }
}

## Epsilon
sub epsilon() is export(:MANDATORY, :ALL) {
    -> @x {((@x, ()),) }
}

## Succeed
proto sub success(|) is export(:MANDATORY, :ALL) {*}

multi sub success() {
    -> @x { ((@x, ()),) }
}

multi sub success($v){
    -> @x { ((@x, $v),) }
}

## Fail
sub failure is export(:MANDATORY, :ALL) {
    { () }
}

#============================================================
# Combinators
#============================================================

## Sequence
proto sequence(|) is export(:MANDATORY, :ALL) {*}

multi sub sequence(&p) {&p}

multi sub sequence(&p1, &p2) {
    -> @x {
        my @res1 = &p1(@x);
        if !(@res1 ~~ Iterable && @res1.elems) {
            ()
        } else {
            my @flatRes;
            @res1.map( -> @r {
                my @res2 = &p2(@r.head);
                if @res2 {
                    @flatRes.append( @res2.map({ ($_[0], (@r[1], $_[1]))  }) )
                } else {
                    Empty
                }
            });
            @flatRes.List
        }
    }
}

multi sub sequence(*@args where @args.elems > 2 && @args.all ~~ Callable )  {
    reduce({sequence($^b, $^a)}, @args.tail, |@args.reverse.tail(*-1).List)
}

# Infix ⨂
sub infix:<«&»>( *@args ) is equiv( &infix:<&&> ) is assoc<right> is export(:double, :ALL) {
    sequence(|@args)
}

sub infix:<(&)>( *@args ) is equiv( &infix:<&&> ) is assoc<right> is export(:set) {
    sequence(|@args)
}

sub infix:<⨂>( *@args ) is equiv( &infix:<&&> ) is assoc<right> is export(:n-ary) {
    sequence(|@args)
}

## Alternatives
sub alternatives(*@args) is export(:MANDATORY, :ALL) {
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

## Alternatives first match
sub alternatives-first-match(*@args) is export(:MANDATORY, :ALL) {
    -> @x {
        my @res;
        my @res2;
        for @args {
            @res2 = $_(@x);
            @res.append(@res2);
            last if @res2 && @res2.head.head.elems < @x.elems;
        }
        @res2 ?? @res2.List !! @res;
    }
}

# Infix ⨁
sub infix:<«||»>( *@args ) is equiv( &infix:<||> ) is assoc<list> is export(:double, :ALL) {
    alternatives-first-match(|@args)
}

sub infix:<(||)>( *@args ) is equiv( &infix:<||> ) is assoc<list> is export(:set, :ALL) {
    alternatives-first-match(|@args)
}

sub infix:<⨁⨁>( *@args ) is equiv( &infix:<||> ) is assoc<list> is export(:n-ary, :ALL) {
    alternatives-first-match(|@args)
}

#============================================================
# Next combinators
#============================================================

## Space
## (See the shortcuts below -- sp can be used instead.)
sub drop-spaces(&p) is export(:MANDATORY, :ALL) {
    -> @x {
        my $k = 0;
        for @x { last if $_.head.chars && $_.head !~~ / \s+ /; $k++ };
        &p(@x[$k..*-1])
    }
}

## Just
sub just(&p) is export(:MANDATORY, :ALL) {
    -> @x { my @res = &p(@x); @res.grep({ $_[0].elems == 0 }) }
}

## Some
sub some(&p) is export(:MANDATORY, :ALL) {
    -> @x { just(&p)(@x).head[1] }
}

## Shortest
sub shortest(&p) is export(:MANDATORY, :ALL) {
    -> @x { &p(@x).sort({ $_.head.elems })[^1] }
}

## Apply
sub apply(&f, &p) is export(:MANDATORY, :ALL) {
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
sub sequence-pick-left(&p1, &p2) is export(:MANDATORY, :ALL) {
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
sub sequence-pick-right(&p1, &p2) is export(:MANDATORY, :ALL) {
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
sub pack(&s1, &p, &s2) is export(:MANDATORY, :ALL) {
    # Same as: apply({ $_[0][1]}, sequence(&s1, &p, &s2))
    sequence-pick-left(sequence-pick-right(&s1, &p), &s2)
}

# Parse parenthesized
sub parenthesized(&p) is export(:MANDATORY, :ALL) {
    pack(symbol('('), &p, symbol(')'))
}

# Parse bracketed
sub bracketed(&p) is export(:MANDATORY, :ALL) {
    pack(symbol('['), &p, symbol(']'))
}

# Parse curly bracketed
sub curly-bracketed(&p) is export(:MANDATORY, :ALL) {
    pack(symbol('{'), &p, symbol('}'))
}

# Parse option
sub option(&p) is export(:MANDATORY, :ALL) {
    alternatives(apply({($_,)}, &p), epsilon)
}

# Parse many
sub many(&p) is export(:MANDATORY, :ALL) {
    -> @x { alternatives(apply( {($_[0], |$_[1])}, sequence(&p, many(&p))), success())(@x) }
}

# Parse many1
sub many1(&p) is export(:MANDATORY, :ALL) {
    apply({($_[0], |$_[1])}, sequence(&p, many(&p)))
}

# List of
sub list-of(&p, &sep) is export(:MANDATORY, :ALL) {
    alternatives(apply({($_[0], |$_[1])}, sequence(&p, many(sequence-pick-right(&sep, &p)))), success())
}

# Chain left
sub chain-left(&p, &sep) is export(:MANDATORY, :ALL) {
    apply( { reduce( { $^b[0]($^a, $^b[1]) }, $_.head, |$_[1]) }, sequence(&p, many1(sequence(&sep, &p))))
}

# Chain right
sub chain-right(&p, &sep) is export(:MANDATORY, :ALL) {
    apply( { reduce( { $^b[1]($^b[0], $^a) }, $_[1], |$_[0].reverse) }, sequence(many1(sequence(&p, &sep)), &p))
}

#============================================================
# Backtracking related
#============================================================

# First
sub take-first(&p) is export(:MANDATORY, :ALL) {
    -> @x { my $res = &p(@x); ($res.head,) }
}

# Greedy
sub greedy(&p) is export(:MANDATORY, :ALL) {
    take-first(many(&p))
}

# Greedy1
sub greedy1(&p) is export(:MANDATORY, :ALL) {
    take-first(many1(&p))
}

# Compulsion
sub compulsion(&p) is export(:MANDATORY, :ALL) {
    take-first(option(&p))
}

#============================================================
# Extra parsers
#============================================================

constant &pInteger is export(:extra, :ALL) = apply({ $_.join.Int }, many1(satisfy({ $_ ~~ / \d+ /})));
constant &pNumber is export(:extra, :ALL) = apply({ $_.join.Num }, many1(satisfy({ $_ ~~ / [ \d | '.' | 'e' | 'E' ]+ /})));

constant &pWord is export(:extra, :ALL) = apply({ $_.flat.join }, many1(satisfy({ $_ ~~ / \w+ /})));
constant &pLetterWord is export(:extra, :ALL) = apply({ $_.flat.join }, many1(satisfy({ $_ ~~ / [<:Ll> | <:Lu>]+ /})));
constant &pIdentifier is export(:extra, :ALL) = apply({ $_.flat.join }, sequence(satisfy({$_ ~~ / <alpha> / }), many(satisfy({ $_ ~~ / <alnum>+ /}))));

#============================================================
# Shortcuts
#============================================================

constant &sp is export(:shortcuts, :ALL) = &drop-spaces;

constant &seq is export(:shortcuts, :ALL) = &sequence;
constant &seql is export(:shortcuts, :ALL) = &sequence-pick-left;
constant &seqr is export(:shortcuts, :ALL) = &sequence-pick-right;

constant &and is export(:shortcuts, :ALL) = &sequence;
constant &andl is export(:shortcuts, :ALL) = &sequence-pick-left;
constant &andr is export(:shortcuts, :ALL) = &sequence-pick-right;

constant &alt is export(:shortcuts, :ALL) = &alternatives;
constant &or is export(:shortcuts, :ALL) = &alternatives;
