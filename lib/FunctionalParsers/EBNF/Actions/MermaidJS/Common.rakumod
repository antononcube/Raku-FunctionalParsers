use v6.d;

use FunctionalParsers::EBNF::Actions::Common;

role FunctionalParsers::EBNF::Actions::MermaidJS::Common {

    has %.nodes;
    has @.rules;
    has $.tranceIndex = 0;

    method make-mmd-node(Str $spec, $ext is copy = Whatever) {

        my ($name, $node);

        if $ext.isa(Whatever) {
            $ext = $!tranceIndex.Str;
            $!tranceIndex += 1;
        }

        given $spec {
            when 'alt' {
                $name = "alt{$ext}";
                $node = '((or))';
            }

            when 'seq' {
                $name = "seq{$ext}";
                $node = '((and))';
            }

            when 'parens' {
                $name = "parens{$ext}";
                $node = '((block))';
            }

            when 'opt' {
                $name = "opt{$ext}";
                $node = '((?))';
            }

            when 'rep' {
                $name = "rep{$ext}";
                $node = '((*))';
            }

            when $_ ~~ / ^ '<' <-[<>]>+ '>' $ / {
                $name = $_.substr(1, *- 1);
                $node = "[$name]";
                $name = "NT:{ $name }";
                %!nodes{$name} = $node;
            }

            when $_ ~~ / ^ ['\'' | '"'] <-['"]>+ '\'' | '"' $ / {
                $name = $_.substr(1, *- 1);
                $node = "($name)";
                $name = "T:{ $name }";
            }

            default {
                note 'Cannot process: ', $_.raku;
                $name = $_;
                $node = $_;
            }
        }

        %!nodes{$name} = $node;

        return $name
    }
}