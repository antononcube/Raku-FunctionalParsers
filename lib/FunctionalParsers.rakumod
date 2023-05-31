use v6.d;

unit module FunctionParsers;

#============================================================
# Basic parsers
#============================================================

## Symbol
sub symbol(Str $a) is export {
    -> @x { @x.elems && @x[0] eq $a ?? ((@x.tail(*- 1).List, $a),) !! () };
}

## Token
sub token(Str $k) is export {
    -> @x { @x.elems >= $k.chars && @x[^$k.chars].join eq $k ?? ((@x.tail(*- $k.chars).List, $k),) !! () };
}

## Satisfy
sub satisfy(&pred) is export {
    -> @x { @x.elems && &pred(@x[0]) ?? ((@x.tail(*- 1).List, @x.head),) !! () };
}

## Epsilon
sub epsilon() is export {
    -> @x { (@x, ()) }
}

## Succeed
proto sub success(|) is export {*}

multi sub success() {
    -> @x { (@x, ()) }
}

multi sub success($v){
    -> @x { (@x, $v) }
}

## Fail
sub failure is export {
    { () }
}

#============================================================
# Parse combinators
#============================================================

sub compose-with-results(&p) is export {
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
proto sub seq(|) is export {*}

multi sub seq(&p)  {
    -> @x { &p(@x) }
}

multi sub seq(*@args where @args.elems > 1)  {
    -> @x { @args[0](@x); reduce({ compose-with-results($^b)($^a) }, @args[0](@x), |@args.tail(*-1).List) }
}

sub infix:<«&»>( *@args ) is equiv( &[&] ) is export {
    seq(|@args);
}

## Alternation
sub alt(*@args) is export {
    -> @x { my @res; @args.map({ @res.append( $_(@x) ) }); @res.List }
}

# ⨁
sub infix:<«|»>( *@args )  is equiv( &[|] ) is export {
    alt(|@args);
}

#============================================================
# Next combinators
#============================================================

## Space
sub sp(&p) is export {
    -> @x {
        my $k=0;
        for @x { last if !($_.head ~~ / \s+ /); $k++ };
        &p(@x[$k..*-1])
    }
}

## Just
sub just(&p) is export {
    -> @x { my @res = &p(@x); @res.grep({ $_[0].elems == 0 }); }
}

## Some
sub some(&p) is export {
    -> @x { just(&p)(@x).head[1] }
}

## Apply
sub apply(&f, &p) is export {
    -> @x { &p(@x).map({ ($_[0], &f($_[1])) }) }
}

# ⨀
sub infix:<«o>( &p, &f ) is equiv( &[o] ) is export {
    apply(&f, &p);
}

## Pick left
sub seql(&p1, &p2) is export {
    apply( {$_[0]}, seq(&p1, &p2))
}

sub infix:<«&>( &p1, &p2 ) is equiv( &[&] ) is export {
    seql(&p1, &p2);
}

## Pick right
sub seqr(&p1, &p2) is export {
    apply( {$_[1]}, seq(&p1, &p2))
}

sub infix:<&»>( &p1, &p2 ) is equiv( &[&] ) is export {
    seqr(&p1, &p2);
}