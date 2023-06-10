use v6.d;

# This class can be implementing by inheriting
#   FunctionalParsers::Actions::EBNFParserCode
# But it seems simpler to just put all definitions here.

class FunctionalParsers::Actions::EBNFParserClassAttr {
    has Str $.name = 'FP';
    has Str $.prefix is rw = 'p';

    has &.terminal = {"symbol($_)"};

    has &.non-terminal = {"self.{self.prefix}" ~ $_.uc.subst(/\s/,'').substr(1,*-1)};

    has &.option = {"option($_)"};

    has &.repetition = {"many($_)"};

    has &.sequence = { $_ ~~ Positional && $_.elems > 1 ?? "sequence({$_.join(', ')})" !! $_ };

    has &.alternatives = { $_ ~~ Positional && $_.elems > 1 ?? "alternatives({$_.join(', ')})" !! $_ };

    has &.parens = {$_};

    has &.node = {$_};

    has &.term = { self.sequence.($_) };

    has &.expr = { self.alternatives.($_) };

    has &.rule = { "has {self.non-terminal.($_[0]).subst(/ ^ 'self.'/, '&.')} is rw = {$_[1]};" };

    has &.grammar = {
        my $code = "class {self.name} \{\n\t";
        $code ~= $_.join("\n\t");
        $code ~= "\n\tmethod parse(@x) \{ self.pTOP.(@x) \}";
        $code ~= "\n}";
        $code;
    }
}