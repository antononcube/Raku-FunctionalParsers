#!/usr/bin/env raku
use v6.d;

use lib '.';
use lib './lib';

use FunctionalParsers :ALL;

#use Data::Dump::Tree;

my %entities =
        'antanta' => 'Atlanta-GA-USA',
        'antanta usa' => 'Atlanta-GA-USA',
        'chicago' => 'Chicago-IL-USA',
        'chicago il' => 'Chicago-IL-USA';

my $entitiesWords = %entities.keys>>.split(/\s/).flat.Set;

my %keywords =
        'alternate standard names' => 'AlternateStandardNames',
        'cloud cover fraction' => 'CloudCoverFraction',
        'cloud height' => 'CloudHeight',
        'cloud types' => 'CloudTypes',
        'conditions' => 'Conditions',
        'coordinates' => 'Coordinates',
        'dew point' => 'DewPoint',
        'elevation' => 'Elevation',
        'humidity' => 'Humidity',
        'latitude' => 'Latitude',
        'longitude' => 'Longitude',
        'max temperature' => 'MaxTemperature',
        'max wind speed' => 'MaxWindSpeed',
        'mean dew point' => 'MeanDewPoint',
        'mean humidity' => 'MeanHumidity',
        'mean pressure' => 'MeanPressure',
        'mean station pressure' => 'MeanStationPressure',
        'mean temperature' => 'MeanTemperature',
        'mean visibility' => 'MeanVisibility',
        'mean wind chill' => 'MeanWindChill',
        'mean wind speed' => 'MeanWindSpeed',
        'memberships' => 'Memberships',
        'min temperature' => 'MinTemperature',
        'ncdcid' => 'NCDCID',
        'precipitation amount' => 'PrecipitationAmount',
        'precipitation rate' => 'PrecipitationRate',
        'precipitation types' => 'PrecipitationTypes',
        'pressure' => 'Pressure',
        'pressure tendency' => 'PressureTendency',
        'snow accumulation' => 'SnowAccumulation',
        'snow accumulation rate' => 'SnowAccumulationRate',
        'snow depth' => 'SnowDepth',
        'station name' => 'StationName',
        'station pressure' => 'StationPressure',
        'temperature' => 'Temperature',
        'total precipitation' => 'TotalPrecipitation',
        'visibility' => 'Visibility',
        'wbanid' => 'WBANID',
        'wind chill' => 'WindChill',
        'wind direction' => 'WindDirection',
        'wind gusts' => 'WindGusts',
        'wind speed' => 'WindSpeed',
        'wmoid' => 'WMOID';

my $keywordWords = %keywords.keys>>.split(/\s/).flat.Set;


## Lookup Satisfy
sub lookup-satisfy(UInt $k, %dict) is export(:DEFAULT) {
    -> @x { @x.elems ≥ $k && (%dict{@x[^$k].join(' ')}:exists) ?? ((@x.tail(*- $k).List, @x.head($k)),) !! () };
}

#============================================================

say lookup-satisfy(2, %keywords)('max temperature'.words);

my &pKeyword = (lookup-satisfy(3, %keywords) (|) lookup-satisfy(2, %keywords) (|) lookup-satisfy(1, %keywords)) (^)
        { %keywords{$_.join(' ')} };

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
    'show the times series of max temperature pressure',
    'max temperature pressure wind speed and something else',
    'max temperature pressure wind speed cloud cover fraction',
    'max temperature pressure wind speed cloud cover fraction and something else',
    'filler1 filler2 max temperature pressure wind speed cloud cover fraction and something else',
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
        [<pre-filler> \h+]?
        <entity-name-list>
        [\h* <post-filler>]?
        ||
        [<pre-filler> \h+]?
        <heuristic-entity-name-list>
        [\h* <post-filler>]?

        { make ($<pre-filler> ?? $<pre-filler>.made !! 0,
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

        <?{ %keywords{$0.Str}:exists }>

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
        <!{ $0.Str ∈ $keywordWords }>
    }
}

for @commads -> $cmd {
    say '=' x 120;
    say $cmd;
    say '-' x 120;
    my $tstart = now;
    my $res = Lookup.parse($cmd).made;
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