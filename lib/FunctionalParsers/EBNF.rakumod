use v6.d;

use FunctionalParsers;
use FunctionalParsers::EBNF::Actions::Raku::Class;
use FunctionalParsers::EBNF::Actions::Raku::Code;
use FunctionalParsers::EBNF::Actions::Raku::Pairs;
#use FunctionalParsers::EBNF::Actions::Raku::EBNFParserRandom;
use FunctionalParsers::EBNF::Actions::WL::Code;
use FunctionalParsers::EBNF::Parser::FromTokens;

unit module FunctionParsers::EBNF;

#============================================================
# Interpretation
#============================================================
proto sub parse-ebnf($x,|) is export(:MANDATORY, :ALL) {*}

multi sub parse-ebnf(@x,
                     :$actions = Whatever,
                     :$name is copy = Whatever,
                     :$parser-prefix is copy = Whatever,
                     :to(:$to-lang) is copy = Whatever,
                     Bool :$eval = True) {

    # Process parser-prefix
    if $parser-prefix.isa(Whatever) { $parser-prefix = 'p'; }
    die 'The argument $parser-prefix is expected to be a string or Whatever.'
    unless $parser-prefix ~~ Str;

    # Process target
    if $to-lang.isa(Whatever) { $to-lang = 'Raku'; }
    die 'The argument $to-lang is expected to be a Whatever or one of <Raku WL>.'
    unless $to-lang ~~ Str && $to-lang ∈ <Raku WL>;

    given $actions {
        when Whatever {
            $FunctionalParsers::EBNF::Parser::FromTokens::ebnfActions = FunctionalParsers::EBNF::Actions::Raku::Pairs.new;
            return FunctionalParsers::EBNF::Parser::FromTokens::pEBNF(@x).List;
        }

        when $_ ∈ <code parser-code> {
            $FunctionalParsers::EBNF::Parser::FromTokens::ebnfActions = ::("FunctionalParsers::EBNF::Actions::{$to-lang}::Code").new;
            return pEBNF(@x);
        }

        when $_ ∈ <class parser-class> {

            # React to $to-lang if needed
            if $to-lang ne 'Raku' {
                warn "The value of $to-lang is expected to be 'Raku' when \$actions is '$actions'.";
            }

            # Process name
            if $name.isa(Whatever) { $name = 'FP'; }
            die "The argument \$name is expected to be a string or Whatever."
            unless $name ~~ Str;

            # Make parser generator
            $FunctionalParsers::EBNF::Parser::FromTokens::ebnfActions = FunctionalParsers::EBNF::Actions::Raku::Class.new(:$name, prefix => $parser-prefix);

            # Generate code of parser class
            my $res = pEBNF(@x).List;

            # Evaluate the class
            if $eval {
                use MONKEY-SEE-NO-EVAL;
                $res = EVAL $res.head.tail;
            }

            # Result
            return $res;
        }

        default {
            die 'Do not know how interpret the value of the argument $actions.';
        }
    }
}


#============================================================
# Random sentences
#============================================================
#proto random-sentences($ebnf, |) is export(:MANDATORY, :ALL) {*}
#
#multi sub random-sentences($ebnf, UInt $n = 1) {
#    $ebnfActions = FunctionalParsers::EBNF::Actions::Raku::EBNFParserRandom.new;
#    my @tokens = $ebnf.split(/ \s /, :skip-empty);
#    return (^$n).map({ pEBNF(@tokens).head.tail });
#}