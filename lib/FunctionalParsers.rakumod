use v6.d;

unit module FunctionParsers;

#============================================================
# Basic parsers
#============================================================

## Symbol
sub symbol(Str $a) is export(:DEFAULT) {
    -> @x { @x.elems && @x[0] eq $a ?? ((@x.tail(*- 1).List, $a),) !! () };
}

## Token
sub token(Str $k) is export(:DEFAULT) {
    -> @x { @x.elems >= $k.chars && @x[^$k.chars].join eq $k ?? ((@x.tail(*- $k.chars).List, $k),) !! () };
}

## Satisfy
sub satisfy(&pred) is export(:DEFAULT) {
    -> @x { @x.elems && &pred(@x[0]) ?? ((@x.tail(*- 1).List, @x.head),) !! () };
}

## Epsilon
sub epsilon() is export(:DEFAULT) {
    -> @x { (@x, ()) }
}

## Succeed
proto sub success(|) is export(:DEFAULT) {*}

multi sub success() {
    -> @x { (@x, ()) }
}

multi sub success($v){
    -> @x { (@x, $v) }
}

## Fail
sub failure is export(:DEFAULT) {
    { () }
}

#============================================================
# Parse combinators
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

multi sub sequence(&p)  {
    -> @x { &p(@x) }
}

multi sub sequence(*@args where @args.elems > 1)  {
    -> @x { @args[0](@x); reduce({ compose-with-results($^b)($^a) }, @args[0](@x), |@args.tail(*-1).List) }
}

sub infix:<«&»>( *@args ) is equiv( &[(&)] ) is export(:double, :ALL) {
    sequence(|@args);
}

sub infix:<(&)>( *@args ) is equiv( &[(&)] ) is export(:set) {
    sequence(|@args);
}

sub infix:<⨂>( *@args ) is equiv( &[(&)] ) is export(:n-ary) {
    sequence(|@args);
}

## Alternatives
sub alternatives(*@args) is export(:DEFAULT) {
    -> @x { my @res; @args.map({ @res.append( $_(@x) ) }); @res.List }
}

# ⨁
sub infix:<«|»>( *@args ) is equiv( &[(|)] ) is export(:double, :ALL) {
    alternatives(|@args);
}

sub infix:<(|)>( *@args ) is equiv( &[(|)] ) is export(:set, :ALL) {
    alternatives(|@args);
}

sub infix:<⨁>( *@args ) is equiv( &[(|)] ) is export(:n-ary, :ALL) {
    alternatives(|@args);
}

#============================================================
# Next combinators
#============================================================

## Space
sub sp(&p) is export(:DEFAULT) {
    -> @x {
        my $k=0;
        for @x { last if !($_.head ~~ / \s+ /); $k++ };
        &p(@x[$k..*-1])
    }
}

## Just
sub just(&p) is export(:DEFAULT) {
    -> @x { my @res = &p(@x); @res.grep({ $_[0].elems == 0 }); }
}

## Some
sub some(&p) is export(:DEFAULT) {
    -> @x { just(&p)(@x).head[1] }
}

## Apply
sub apply(&f, &p) is export(:DEFAULT) {
    -> @x { &p(@x).map({ ($_[0], &f($_[1])) }) }
}

# ⨀
sub infix:<«o>( &p, &f ) is equiv( &[xx] ) is export(:double, :ALL) {
    apply(&f, &p);
}

sub infix:<(^)>( &p, &f ) is equiv( &[xx] ) is export(:set, :ALL) {
    apply(&f, &p);
}

sub infix:<⨀>( &f, &p ) is equiv( &[xx] ) is export(:n-ary, :ALL) {
    apply(&f, &p);
}

## Pick left
sub sequence-pick-left(&p1, &p2) is export(:DEFAULT) {
    apply( {$_[0]}, sequence(&p1, &p2))
}

sub infix:<«&>( &p1, &p2 ) is equiv( &[(&)] ) is export(:double, :ALL) {
    sequence-pick-left(&p1, &p2);
}

sub infix:<(\<&)>( &p1, &p2 ) is equiv( &[(&)] ) is export(:set, :ALL) {
    sequence-pick-left(&p1, &p2);
}

sub infix:<◁>( &p1, &p2 ) is equiv( &[(&)] ) is export(:n-ary, :ALL) {
    sequence-pick-left(&p1, &p2);
}

## Pick right
sub sequence-pick-right(&p1, &p2) is export(:DEFAULT) {
    apply( {$_[1]}, sequence(&p1, &p2))
}

sub infix:<\&\>>( &p1, &p2 ) is equiv( &[(&)] ) is export(:double, :ALL) {
    sequence-pick-right(&p1, &p2);
}

sub infix:<(»)>( &p1, &p2 ) is equiv( &[(&)] ) is export(:set, :ALL) {
    sequence-pick-right(&p1, &p2);
}

sub infix:<▷>( &p1, &p2 ) is equiv( &[(&)] ) is export(:n-ary, :ALL) {
    sequence-pick-right(&p1, &p2);
}