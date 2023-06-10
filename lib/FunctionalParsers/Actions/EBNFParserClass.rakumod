use v6.d;

class FunctionalParsers::Actions::EBNFParserClass {
    has Str $.name = 'FP';

    has &.terminal = {"symbol($_)"};

    has &.non-terminal = {"self.p" ~ $_.uc.subst(/\s/,'').substr(1,*-1)};

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