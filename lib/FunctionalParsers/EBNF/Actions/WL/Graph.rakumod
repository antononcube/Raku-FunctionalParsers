use v6.d;

use FunctionalParsers::EBNF::Actions::MermaidJS::Graph;

class FunctionalParsers::EBNF::Actions::WL::Graph
        is FunctionalParsers::EBNF::Actions::MermaidJS::Graph {

    method edge-spec(Str $start, Str $end, Str $tag = '', Str :$con = 'DirectedEdge') {
        $tag ?? "$con\[\"$start\", \"$end\", \"$tag\"\]" !! "$con\[\"$start\", \"$end\"\]";
    }

    method make-mmd-node(Str $spec, $ext is copy = Whatever) {

        my ($name, $node);

        if $ext.isa(Whatever) {
            $ext = self.tranceIndex.Str;
            self.tranceIndex += 1;
        }

        given $spec {
            when 'apply' {
                $name = "apply{$ext}";
                $node = <"@" "Circle">;
            }

            when 'alt' {
                $name = "alt{$ext}";
                $node = <"or" "Circle">;
            }

            when 'seq' {
                $name = "seq{$ext}";
                $node = <"and" "Circle">;
            }

            when 'seqL' {
                $name = "seqL{$ext}";
                $node = <"«and" "Circle">;
            }

            when 'seqR' {
                $name = "seqR{$ext}";
                $node = <"and»" "Circle">;
            }

            when 'parens' {
                $name = "parens{$ext}";
                $node = <"()" "Circle">;
            }

            when 'opt' {
                $name = "opt{$ext}";
                $node = <"?" "Circle">;
            }

            when 'rep' {
                $name = "rep{$ext}";
                $node = <"*" "Circle">;
            }

            when $_ ~~ / ^ '<' <-[<>]>+ '>' $ / {
                $name = $_.substr(1, *- 1);
                $node = ("\"$name\"", "\"Rectangle\"");
                $name = "NT:{ $name }";
                self.nodes{$name} = $node;
            }

            when $_ ~~ / ^ ['\'' | '"'] <-['"]>+ '\'' | '"' $ / {
                $name = $_.substr(1, *- 1);
                $node = ("\"$name\"", "\"Capsule\"");
                $name = "T:{ $name }";
            }

            default {
                note 'Cannot process: ', $_.raku;
                $name = $_;
                $node = $_;
            }
        }

        self.nodes{$name} = $node;

        return $name
    }

    multi method trace($p where self.is-paired-with('EBNF', $p)) {
        my @res = $p.value.map({ self.trace($_) });
        my $code = "Graph[";
        $code ~= '{' ~ self.rules.unique.join(',') ~ '},';
        $code ~= "\nVertexLabels -> \{" ~ self.nodes.map({ "\"{$_.key}\" -> Placed[{$_.value.head}, Center]" }).join(',') ~ "\},";
        $code ~= "\nVertexShapeFunction -> \{" ~ self.nodes.map({ "\"{$_.key}\" -> {$_.value[1]}" }).join(',') ~ "\},";
        $code ~= "\nVertexSize -> 0.7";
        $code ~= "]";

        return $code;
    }
}