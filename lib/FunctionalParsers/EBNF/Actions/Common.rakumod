use v6.d;

role FunctionalParsers::EBNF::Actions::Common {
    has Str $.name = 'FP';
    has Str $.prefix = 'p';
    has Str $.start = 'top';
    has &.modifier = {$_.uc};
    method top-rule-name { self.prefix ~ self.modifier.(self.start) }
    method setup-code { 'use FunctionalParsers;' }
}