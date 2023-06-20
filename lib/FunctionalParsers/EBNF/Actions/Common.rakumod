use v6.d;

role FunctionalParsers::EBNF::Actions::Common {
    has Str $.name is rw = 'FP';
    has Str $.prefix is rw  = 'p';
    has Str $.start is rw = 'top';
    has &.modifier is rw = {$_.uc};
    method top-rule-name { self.prefix ~ self.modifier.(self.start) }
    method setup-code { 'use FunctionalParsers;' }
}