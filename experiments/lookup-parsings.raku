#!/usr/bin/env raku
use v6.d;

use lib '.';
use lib './lib';

use DSL::Entity::WeatherData;
use FunctionalParsers :ALL;
#use Data::Dump::Tree;

my %entities =
        'antanta' => 'Atlanta-GA-USA',
        'antanta usa' => 'Atlanta-GA-USA',
        'chicago' => 'Chicago-IL-USA',
        'chicago il' => 'Chicago-IL-USA';

my $entitiesWords = %entities.keys>>.split(/\s/).flat.Set;

my DSL::Entity::WeatherData::ResourceAccess $resObj = DSL::Entity::WeatherData::resource-access-object;
my %keywords = $resObj.getNameToEntityID<Variable>;

say "%keywords.elems = {%keywords.elems}";

my $keywordWords = $resObj.getKnownNameWords<Variable>;

say $keywordWords.raku;

note %keywords{'max temperature'};

#============================================================
## Lookup Satisfy
sub lookup-satisfy(UInt $k, %dict) is export(:DEFAULT) {
    -> @x { @x.elems ≥ $k && (%dict{@x[^$k].join(' ')}:exists) ?? ((@x.tail(*- $k).List, @x.head($k)),) !! () };
}

#============================================================

say lookup-satisfy(2, %keywords)('max temperature'.words);

my &pKeyword = (lookup-satisfy(3, %keywords) (|) lookup-satisfy(2, %keywords) (|) lookup-satisfy(1, %keywords)) (^) { %keywords{$_.join(' ')} };

say &pKeyword('max temperature and pressure'.words);

say (&pKeyword «& symbol('and') «&» &pKeyword)('max temperature and pressure'.words);

say (&pKeyword)('max temperature and pressure'.words).raku;

say option(symbol('and'))('and pressure'.words).raku;

say (&pKeyword (&) option(symbol('and')))('max temperature and pressure'.words);

say (&pKeyword (&) option(symbol('and')) (&) &pKeyword)('max temperature and pressure'.words);

my $tstart = now;
say (&pKeyword (&) option(symbol('and')) (&) &pKeyword (&) option(symbol('and')) (&) &pKeyword)('max temperature pressure wind speed'
        .words);
my $tend = now;
say "Parsing time: { $tend - $tstart }";

say '-' x 120;

my @commads = [
    'max temperature pressure',
#    'show the times series of max temperature pressure',
#    'max temperature pressure wind speed and something else',
#    'max temperature pressure wind speed cloud cover fraction',
#    'max temperature pressure wind speed cloud cover fraction and something else',
#    'filler1 filler2 max temperature pressure wind speed cloud cover fraction and something else',
];

for @commads -> $cmd {
    say '=' x 120;
    say $cmd;
    say '-' x 120;
    my $tstart = now;
    my $mRes = shortest(sequence(apply({ 'PRE-FILLER' => $_.elems }, many(satisfy({ $_ ∉ $keywordWords }))), many(&pKeyword)))($cmd.words);
    my $tend = now;
    say "Parsing time: { $tend - $tstart }";
    say $mRes.raku;
}
#ddt $mRes;


#============================================================
# Using grammar with lookup
#============================================================

say '❖' x 120;
say 'Parsing with grammar';
say '❖' x 120;


grammar Lookup {
    regex TOP {
        [
        [<pre-filler> \h+]?
        <entity-name-list>
        [\h* <post-filler>]?
        ||
        [<pre-filler> \h+]?
        <entity-name-list>
        [\h* <post-filler>]?]

        { make (($<pre-filler> // False) ?? $<pre-filler>.made !! 0,
                $<entity-name-list>.made,
                $<post-filler>.made) }
    }
    regex entity-name-list {
        <entity-name>+ % [\h+ | \h* ',' \h*]
        { make $<entity-name>>>.made }
    }
    regex entity-name-part {
        <.wb> \w+ <.wb>
    }
    regex entity-name {
        (<entity-name-part>+ % \h+)

        <?{ %keywords{$0.Str.trim}:exists }>

        { make %keywords{$0.Str} }
    }
    regex post-filler {
        .*
        { make $/.Str.chars }
    }
    regex pre-filler {
        <pre-filler-part>+ % [\h+]
        { make $/.Str.chars }
    }
    regex pre-filler-part {
        (<entity-name-part>)
        <!{ reduce( &[||], $0.Str.trim.words.map({ $keywordWords{$_}:exists })) }>
    }
}

#============================================================
# Comparison lookup
#============================================================

for @commads -> $cmd {
    say '=' x 120;
    say $cmd;
    say '-' x 120;
    my $tstart = now;
    my $res = Lookup.parse($cmd).made;
    #note 'made : ', Lookup.parse($cmd, actions => Whatever).made;
    my $tend = now;
    say "Grammar parsing time: { $tend - $tstart }";
    $tstart = now;
    my $mRes =
            shortest(sequence(
                    apply({ 'PRE-FILLER' => $_.elems }, many(satisfy({ $_ ∉ $keywordWords }))),
                    many(&pKeyword),
                    apply({ 'POST-FILLER' => $_.elems }, many(satisfy({$_ ∉ $keywordWords}))),))($cmd.words);
    $tend = now;
    say "FP parsing time     : { $tend - $tstart }";
    say $res;
    say $mRes.raku;
}