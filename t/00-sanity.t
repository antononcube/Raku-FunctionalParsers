use v6.d;

use lib '.';
use lib './lib';

use FunctionalParsers;
use FunctionalParsers::EBNF;
use Test;

# Parsers
my &p1 = symbol('one');
my &p2 = symbol('two');
my &p3 = symbol('three');
my &p4 = symbol('four');
my &pM = symbol('million');
my &pTh = symbol('things');

# Query
my $query = 'one million things'.words;
my @words = $query.words.List;

plan *;

## 1
ok token('one')($query.comb);

## 2
ok sequence(&p1, &pM)(@words);

## 3
ok alternatives(&p1, &p2)(@words);

## 4
ok sequence(alternatives(&p1, &p2), &pM)(@words);

## 5
is
        sequence-pick-left(&p1, &p2)(<one two>).head,
        ((), 'one'),
        "one <& two";

## 6
is
        sequence-pick-right(&p1, &p2)(<one two>).head,
        ((), 'two'),
        "one &> two";

## 7
my $ebnfCode7 = "<top> = 'a' | 'b' ;";

my @tokens7 = $ebnfCode7.split(/ \s /, :skip-empty);

ok fp-ebnf-parse(@tokens7), 'Parsing routine works';

## 8
ok fp-ebnf-parse(@tokens7), 'Parsing routine works with :!tokenized';

## 9
ok fp-ebnf-parse($ebnfCode7), 'Parsing routine works with a string';

## 10
ok fp-ebnf-parse($ebnfCode7, target => 'Raku::Code'),
        'Parsing routine works with a string and target => "Raku::Code"';

done-testing;
