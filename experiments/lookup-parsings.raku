#!/usr/bin/env raku
use v6.d;

use lib '.';
use lib './lib';

use FunctionalParsers :ALL;

use Data::Dump::Tree;

my %entities =
        'antanta' => 'Atlanta-GA-USA',
        'antanta usa' => 'Atlanta-GA-USA',
        'chicago' => 'Chicago-IL-USA',
        'chicago il' => 'Chicago-IL-USA';

my $entitiesWords = %entities.keys>>.split(/\s/).flat.Set;

my %keywords =
        'max temperature' => 'MaxTemperature',
        'maximum temperature' => 'MaxTemperature',
        'min temperature' => 'MinTemperature',
        'minimum temperature' => 'MinTemperature',
        'pressure' => 'Pressure',
        'wind speed' => 'WindSpeed',
        'humidity' => 'Humidity',
        'cloud cover fraction' => 'CloudCoverFraction';

my $keywordWords = %keywords.keys>>.split(/\s/).flat.Set;


## Lookup Satisfy
sub lookup-satisfy(UInt $k, %dict) is export(:DEFAULT) {
    -> @x { @x.elems ≥ $k && (%dict{@x[^$k].join(' ')}:exists) ?? ((@x.tail(*- $k).List, @x.head($k)),) !! () };
}

#============================================================

say lookup-satisfy(2, %keywords)('max temperature'.words);

my &pKeyword = (lookup-satisfy(3, %keywords) (|) lookup-satisfy(2, %keywords) (|) lookup-satisfy(1, %keywords)) (^) { %keywords{$_.join(' ')}};

say &pKeyword('max temperature and pressure'.words);

say (&pKeyword «& symbol('and') «&» &pKeyword)('max temperature and pressure'.words);

say (&pKeyword)('max temperature and pressure'.words).raku;

say option(symbol('and'))('and pressure'.words).raku;

say (&pKeyword (&) option(symbol('and')))('max temperature and pressure'.words);

say (&pKeyword (&) option(symbol('and')) (&) &pKeyword)('max temperature and pressure'.words);

my $tstart = now;
say (&pKeyword (&) option(symbol('and')) (&) &pKeyword (&) option(symbol('and')) (&) &pKeyword)('max temperature pressure wind speed'.words);
my $tend = now;
say "Parsing time: {$tend - $tstart}";

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
        my $mRes = shortest(sequence(apply( {'PREFIX' => $_.elems}, many(satisfy({$_ ∉ $keywordWords }))), many(&pKeyword)))($cmd.words);
        my $tend = now;
        say "Parsing time: { $tend - $tstart }";
        say $mRes.raku;
}
#ddt $mRes;


