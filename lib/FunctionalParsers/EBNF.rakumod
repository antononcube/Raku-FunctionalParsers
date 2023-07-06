use v6.d;

use FunctionalParsers;
use FunctionalParsers::EBNF::Actions::EBNF::Standard;
use FunctionalParsers::EBNF::Actions::Java::FuncJ;
use FunctionalParsers::EBNF::Actions::MermaidJS::Graph;
use FunctionalParsers::EBNF::Actions::Raku::Class;
use FunctionalParsers::EBNF::Actions::Raku::Code;
use FunctionalParsers::EBNF::Actions::Raku::Grammar;
use FunctionalParsers::EBNF::Actions::Raku::AST;
use FunctionalParsers::EBNF::Actions::Raku::Random;
use FunctionalParsers::EBNF::Actions::WL::Code;
use FunctionalParsers::EBNF::Actions::WL::Grammar;
use FunctionalParsers::EBNF::Actions::WL::Graph;
use FunctionalParsers::EBNF::Parser::FromTokens;
use FunctionalParsers::EBNF::Parser::Styled;

unit module FunctionalParsers::EBNF;

#============================================================
# Interpretation
#============================================================

#| Parse a given EBNF grammar.
proto sub fp-ebnf-parse(|) is export {*}

multi sub fp-ebnf-parse(Str $x, $properties = Whatever, *%args) {
    my %args2 = %args.grep({ $_.key ne 'tokenized' });
    return fp-ebnf-parse($x.comb.Array, $properties, |%args2);
}

multi sub fp-ebnf-parse(@x,
                        $properties is copy = Whatever,
                        :target(:$actions) is copy = 'Raku::Class',
                        :name(:$parser-name) is copy = Whatever,
                        :prefix(:$rule-name-prefix) is copy = Whatever,
                        :modifier(:&rule-name-modifier) is copy = WhateverCode,
                        :$style is copy = 'Standard',
                        Bool :$tokenized = False,
                        *%args
                        ) {

    # Process parser-prefix
    if $rule-name-prefix.isa(Whatever) { $rule-name-prefix = 'p'; }
    die 'The argument $rule-name-prefix is expected to be a string or Whatever.'
    unless $rule-name-prefix ~~ Str;

    # Process target
    my @expectedTargets = 'Raku::' X~ <AST Class ClassAttr Code Grammar>;
    @expectedTargets.append('WL::' X~ <Code Grammar>);
    @expectedTargets.append('Java::' X~ <FuncJ>);
    @expectedTargets.append('EBNF::' X~ <Standard>);
    @expectedTargets.append('MermaidJS::' X~ <Graph>);

    $actions = do given $actions {
        when Whatever { 'Raku::Class'; }
        when 'Java' { 'Java::FuncJ'; }
        when 'Raku' { 'Raku::Class'; }
        when 'WL' { 'WL::Code'; }
        when 'EBNF' { 'EBNF::Standard'; }
        when 'Mermaid' { 'MermaidJS::Graph'; }
        default { $actions }
    }

    die "The argument $actions is expected to be a Whatever or one of { @expectedTargets.map({ "'$_'" }).join(', ') }."
    unless $actions ~~ Str && $actions ∈ @expectedTargets || $actions !~~ Str;

    # Process name
    if $parser-name.isa(Whatever) { $parser-name = 'FP'; }
    die "The argument \$parser-name is expected to be a string or Whatever."
    unless $parser-name ~~ Str;

    # Process modifier
    if &rule-name-modifier.isa(WhateverCode) { &rule-name-modifier = { $_.uc }; }
    die "The argument &rule-name-modifier is expected to be a callable or WhateverCode."
    unless &rule-name-modifier ~~ Callable;

    # Process property
    my @expectedProperties = <CODE EVAL>;
    my $properties-orig = $properties;
    if $properties.isa(Whatever) { $properties = 'CODE'; }
    if $properties ~~ Str && $properties.lc eq 'all' { $properties = @expectedProperties; }
    if $properties ~~ Str { $properties = [$properties,]; }

    die "The second argument is expected to be Whatever, one of { @expectedProperties.map({ "'$_'" }).join(', ') }, or a list of them."
    unless $properties ~~ Positional && ($properties (&) @expectedProperties).elems > 0;

    note "Unknown properties { $properties (-) @expectedProperties }."
    if ($properties (-) @expectedProperties).elems > 0;

    # The context (or actions) is determined by lang and property.
    # Note that property can be a list.
    my $actionsObj = Whatever;

    if $actions ~~ Str {

        # Make parser generator
        $actionsObj = ::("FunctionalParsers::EBNF::Actions::{ $actions }").new(
                name => $parser-name,
                prefix => $rule-name-prefix,
                modifier => &rule-name-modifier,
                |%args
                );

        die "Cannot create an object of the target class" unless $actionsObj;

    } else {
        $actionsObj = $actions
    }

    my $parsObj;
    if $tokenized {
        $parsObj = FunctionalParsers::EBNF::Parser::FromTokens.new(ebnfActions => $actionsObj, :$style);
    } else {
        $parsObj = FunctionalParsers::EBNF::Parser::Styled.new(ebnfActions => $actionsObj, :$style);
    }
    my &pEBNF = $parsObj.pEBNF;

    # Result struct
    my %res;

    %res<CODE> = &pEBNF.(@x).List;

    if 'EVAL' ∈ $properties && (%res<CODE>:exists) && $actions ∈ <Raku::Class Raku::Grammar> {
        # Evaluate the class / grammar code
        use MONKEY-SEE-NO-EVAL;
        %res<EVAL> = EVAL %res<CODE>.head.tail;
    }

    if !%res {
        die 'Do not know how to interpret with the given arguments.';
    }

    # Result
    if $properties-orig ~~ Positional {
        return %res.grep({ $_.key ∈ $properties }).Hash;
    } else {
        return %res{$properties.head}
    }
}


#============================================================
# Random sentences
#============================================================

#| Generate random sentences for a given grammar.
proto fp-random-sentence($ebnf, |) is export {*}

multi sub fp-random-sentence(@ebnf, *%args) {
    return fp-random-sentence(@ebnf.join("\n"), |%args);
}

multi sub fp-random-sentence($ebnf,
                             UInt $n = 1,
                             UInt :$max-repetitions = 4,
                             UInt :$min-repetitions = 0,
                             Str :$sep = ' ',
                             :$rule is copy = Whatever,
                             Bool :$eval = True,
                             Bool :$restrict-recursion = True,
                             :$no-value is copy = Whatever,
                             :$style is copy = 'Standard'
                             ) {
    # Automatic top rule
    if $rule.isa(Whatever) {
        $rule = 'top';
        if !$ebnf.contains('<top>', :i) {
            if $ebnf ~~ / '<' (<alnum>+) '>' | (<alnum>+) / {
                $rule = $0.Str;
            }
        }
    }

    # Process $no-value
    if $no-value.isa(Whatever) { $no-value = '()'; }

    die 'The value of the argument $no-value is expected to be a string or Whatever.'
    unless $no-value ~~ Str;

    # Create Random actions object
    my $ebnfActions =
            FunctionalParsers::EBNF::Actions::Raku::Random.new(
                    :name('Random_' ~ DateTime.now.Numeric.Num.subst('.', '_')),
                    :prefix('p'),
                    :start($rule),
                    :$max-repetitions,
                    :$min-repetitions,
                    :$restrict-recursion,
                    :$no-value
                    );

    # Parse
    my $parsObj = FunctionalParsers::EBNF::Parser::Styled.new(:$ebnfActions, :$style);
    my &pEBNF = $parsObj.pEBNF;

    # Generate code of parser class
    my $res = &pEBNF.($ebnf.comb).List;

    if $eval {
        # Evaluate the class
        if $eval {
            use MONKEY-SEE-NO-EVAL;
            $res = EVAL $res.head.tail;
        }

        return (^$n).map({ $res.new.parser.().join($sep) });

    } else {
        return $res.head.tail;
    }
}


#============================================================
# Grammar graph
#============================================================

#| Make a graph for a given grammar.
proto fp-grammar-graph($g, |) is export {*}

multi sub fp-grammar-graph(Str $ebnf,
                           :$style is copy = 'Standard',
                           :actions(:$lang) = Whatever,
                           *%args) {

    my $res = fp-ebnf-parse($ebnf, :$style, actions => 'Raku::AST').head.tail;

    return fp-grammar-graph($res.head, :$lang, |%args);
}

multi sub fp-grammar-graph(Pair $ebnfAST where *.key eq 'EBNF',
                           :actions(:$lang) is copy = Whatever,
                           *%args) {

    if $lang.isa(Whatever) { $lang = 'MermaidJS'; }

    die "The value of the argument $lang is expected to be MeramidJS, WL, or Whatever."
    unless $lang ~~ Str && $lang.lc ∈ <mermaid mermaid-js mermaidjs wl mathematica>;

    $lang = do given $lang.lc {
        when $_  ∈ <mermaid mermaid-js mermaidjs> { 'MermaidJS' }
        when $_  ∈ <wl mathematica> { 'WL' }
    }

    my $tracer = ::("FunctionalParsers::EBNF::Actions::{$lang}::Graph").new(|%args);

    return $tracer.trace($ebnfAST);
}
