use v6.d;

use FunctionalParsers;
use FunctionalParsers::EBNF::Actions::Raku::Class;
use FunctionalParsers::EBNF::Actions::Raku::Code;
use FunctionalParsers::EBNF::Actions::Raku::Grammar;
use FunctionalParsers::EBNF::Actions::Raku::Pairs;
use FunctionalParsers::EBNF::Actions::Raku::Random;
use FunctionalParsers::EBNF::Actions::WL::Code;
use FunctionalParsers::EBNF::Actions::WL::Grammar;
use FunctionalParsers::EBNF::Parser::FromCharacters;
use FunctionalParsers::EBNF::Parser::FromTokens;

unit module FunctionalParsers::EBNF;

#============================================================
# Interpretation
#============================================================
proto sub parse-ebnf(|) is export {*}

multi sub parse-ebnf(Str $x, $properties = Whatever, *%args) {
    my %args2 = %args.grep({ $_.key ne 'tokenized'});
    return parse-ebnf($x.trim.comb.Array, $properties, |%args2);
}

multi sub parse-ebnf(@x,
                     $properties is copy = Whatever,
                     :$target is copy = 'Raku::Class',
                     :name(:$parser-name) is copy = Whatever,
                     :prefix(:$rule-name-prefix) is copy = Whatever,
                     :modifier(:&rule-name-modifier) is copy = WhateverCode,
                     Bool :$tokenized = False,
                     ) {

    # Process parser-prefix
    if $rule-name-prefix.isa(Whatever) { $rule-name-prefix = 'p'; }
    die 'The argument $rule-name-prefix is expected to be a string or Whatever.'
    unless $rule-name-prefix ~~ Str;

    # Process target
    my @expectedTargets = 'Raku::' X~ <Class ClassAttr Code Grammar Pairs>;
    @expectedTargets.append('WL::' X~ <Code Grammar>);

    $target = do given $target {
        when Whatever { 'Raku::Class'; }
        when 'Raku' { 'Raku::Class'; }
        when 'WL' { 'WL::Code'; }
        default { $target }
    }

    die "The argument $target is expected to be a Whatever or one of { @expectedTargets.map({ "'$_'" }).join(', ') }."
    unless $target ~~ Str && $target ∈ @expectedTargets;

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
    my $actions = Whatever;

    if $target ~~ Str {

        # Make parser generator
        $actions = ::("FunctionalParsers::EBNF::Actions::{ $target }").new(
                name => $parser-name,
                prefix => $rule-name-prefix,
                modifier => &rule-name-modifier
                );

        die "Cannot create an object of the target class" unless $actions;

    } else {
        $actions = $target
    }

    my &pEBNF;
    if $tokenized {
        $FunctionalParsers::EBNF::Parser::FromTokens::ebnfActions = $actions;
        &pEBNF = &FunctionalParsers::EBNF::Parser::FromTokens::pEBNF;
    } else {
        $FunctionalParsers::EBNF::Parser::FromCharacters::ebnfActions = $actions;
        &pEBNF = &FunctionalParsers::EBNF::Parser::FromCharacters::pEBNF;
    }

    # Result struct
    my %res;

    %res<CODE> = &pEBNF.(@x).List;

    if 'EVAL' ∈ $properties && (%res<CODE>:exists) && $target ∈ <Raku::Class Raku::Grammar> {
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
proto random-sentence($ebnf, |) is export {*}

multi sub random-sentence($ebnf,
                           UInt $n = 1,
                           UInt :$max-repetitions = 4,
                           UInt :$min-repetitions = 0,
                           Str :$sep = ' ',
                           Bool :$eval = True,
                           ) {
    $FunctionalParsers::EBNF::Parser::FromCharacters::ebnfActions =
            FunctionalParsers::EBNF::Actions::Raku::Random.new(
                    :$max-repetitions,
                    :$min-repetitions
                    );

    my &pEBNF = &FunctionalParsers::EBNF::Parser::FromCharacters::pEBNF;

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
