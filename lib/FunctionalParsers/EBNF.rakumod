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
use FunctionalParsers::EBNF::Parser::FromTokens;
use FunctionalParsers::EBNF::Parser::Styled;

unit module FunctionalParsers::EBNF;

#============================================================
# Interpretation
#============================================================
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
                        ) {

    # Process parser-prefix
    if $rule-name-prefix.isa(Whatever) { $rule-name-prefix = 'p'; }
    die 'The argument $rule-name-prefix is expected to be a string or Whatever.'
    unless $rule-name-prefix ~~ Str;

    # Process target
    my @expectedTargets = 'Raku::' X~ <AST Class ClassAttr Code Grammar>;
    @expectedTargets.append('WL::' X~ <Code Grammar>);
    @expectedTargets.append('Java::' X~ <Code>);
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
    unless $actions ~~ Str && $actions ∈ @expectedTargets;

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
                modifier => &rule-name-modifier
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
proto random-sentence($ebnf, |) is export {*}

multi sub random-sentence(@ebnf, *%args) {
    return random-sentence(@ebnf.join("\n"), |%args);
}

multi sub random-sentence($ebnf,
                          UInt $n = 1,
                          UInt :$max-repetitions = 4,
                          UInt :$min-repetitions = 0,
                          Str :$sep = ' ',
                          :$rule is copy = Whatever,
                          Bool :$eval = True,
                          Bool :$restrict-recursion = True,
                          ) {
    # Automatic top rule
    if $rule.isa(Whatever) {
        $rule = 'top';
        if !$ebnf.contains('<top>', :i) {
            if $ebnf ~~ / '<' (<alnum>+) '>'/ {
                $rule = $0.Str;
            }
        }
    }

    my $ebnfActions =
            FunctionalParsers::EBNF::Actions::Raku::Random.new(
                    :name('Random'),
                    :prefix('p'),
                    :start($rule),
                    :$max-repetitions,
                    :$min-repetitions,
                    :$restrict-recursion
                    );

    my $parsObj = FunctionalParsers::EBNF::Parser::Standard.new(:$ebnfActions);
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
