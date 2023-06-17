use v6.d;

use FunctionalParsers;
use FunctionalParsers::EBNF::Actions::Raku::Class;
use FunctionalParsers::EBNF::Actions::Raku::Code;
use FunctionalParsers::EBNF::Actions::Raku::Pairs;
#use FunctionalParsers::EBNF::Actions::Raku::EBNFParserRandom;
use FunctionalParsers::EBNF::Actions::WL::Code;
use FunctionalParsers::EBNF::Parser::FromCharacters;
use FunctionalParsers::EBNF::Parser::FromTokens;

unit module FunctionParsers::EBNF;

#============================================================
# Interpretation
#============================================================
proto sub parse-ebnf($x,|) is export {*}

multi sub parse-ebnf(Str $x, *%args) {
    my %args2 = %args.grep({ $_.key ne 'tokenized' });
    return parse-ebnf($x.comb.Array, :!tokenized, |%args2);
}

multi sub parse-ebnf(@x,
                     :$actions = Whatever,
                     :name(:$parser-name) is copy = Whatever,
                     :prefix(:$parser-prefix) is copy = Whatever,
                     :to(:$to-lang) is copy = Whatever,
                     Bool :$eval = True,
                     Bool :$tokenized = True
                     ) {

    # Process parser-prefix
    if $parser-prefix.isa(Whatever) { $parser-prefix = 'p'; }
    die 'The argument $parser-prefix is expected to be a string or Whatever.'
    unless $parser-prefix ~~ Str;

    # Process target
    if $to-lang.isa(Whatever) { $to-lang = 'Raku'; }
    die 'The argument $to-lang is expected to be a Whatever or one of <Raku WL>.'
    unless $to-lang ~~ Str && $to-lang ∈ <Raku WL>;

    # Process tokenized
    my &pEBNF = $tokenized ?? &FunctionalParsers::EBNF::Parser::FromTokens::pEBNF !! &FunctionalParsers::EBNF::Parser::FromCharacters::pEBNF;

    given $actions {
        when Whatever {
            if $tokenized {
                $FunctionalParsers::EBNF::Parser::FromTokens::ebnfActions = FunctionalParsers::EBNF::Actions::Raku::Pairs.new;
            } else {
                $FunctionalParsers::EBNF::Parser::FromCharacters::ebnfActions = FunctionalParsers::EBNF::Actions::Raku::Pairs.new;
            }
            return &pEBNF.(@x).List;
        }

        when $_ ∈ <code parser-code> {
            if $tokenized {
                $FunctionalParsers::EBNF::Parser::FromTokens::ebnfActions = ::("FunctionalParsers::EBNF::Actions::{ $to-lang }::Code").new;
            } else {
                $FunctionalParsers::EBNF::Parser::FromCharacters::ebnfActions = ::("FunctionalParsers::EBNF::Actions::{ $to-lang }::Code").new;
            }
            return &pEBNF.(@x);
        }

        when $_ ∈ <class parser-class> {

            # React to $to-lang if needed
            if $to-lang ne 'Raku' {
                warn "The value of $to-lang is expected to be 'Raku' when \$actions is '$actions'.";
            }

            # Process name
            if $parser-name.isa(Whatever) { $parser-name = 'FP'; }
            die "The argument \$parser-name is expected to be a string or Whatever."
            unless $parser-name ~~ Str;

            # Make parser generator
            if $tokenized {
                $FunctionalParsers::EBNF::Parser::FromTokens::ebnfActions =
                        FunctionalParsers::EBNF::Actions::Raku::Class.new(name => $parser-name, prefix => $parser-prefix);
            } else {
                $FunctionalParsers::EBNF::Parser::FromCharacters::ebnfActions =
                        FunctionalParsers::EBNF::Actions::Raku::Class.new(name => $parser-name, prefix => $parser-prefix);
            }

            # Generate code of parser class
            my $res = &pEBNF.(@x).List;

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
