
## Functional parsers

<table>
  <tr>
    <th>Type</th>
    <th>Symbol</th>
    <th>Description</th>
    <th>Parameters</th>
    <th>Returns</th>
  </tr>
  <tr>
    <td>Basic Parsers</td>
    <td>sub symbol(Str $a)</td>
    <td>Parses a single symbol.</td>
    <td>$a: The symbol to match.</td>
    <td>A callable that attempts to match the symbol.</td>
  </tr>
  <tr>
    <td>Basic Parsers</td>
    <td>sub token(Str $k)</td>
    <td>Parses a sequence of characters (token).</td>
    <td>$k: The token to match.</td>
    <td>A callable that attempts to match the token.</td>
  </tr>
  <tr>
    <td>Basic Parsers</td>
    <td>sub satisfy(&pred)</td>
    <td>Parses a single element that satisfies a predicate.</td>
    <td>&pred: A predicate function to satisfy.</td>
    <td>A callable that attempts to match an element satisfying the predicate.</td>
  </tr>
  <tr>
    <td>Basic Parsers</td>
    <td>sub epsilon()</td>
    <td>Always succeeds without consuming any input.</td>
    <td></td>
    <td>A callable that always succeeds.</td>
  </tr>
  <tr>
    <td>Basic Parsers</td>
    <td>proto sub success(|)</td>
    <td>Always succeeds, optionally returning a value.</td>
    <td></td>
    <td>Variants: multi sub success(): Succeeds with no value. multi sub success($v): Succeeds with a value $v.</td>
  </tr>
  <tr>
    <td>Basic Parsers</td>
    <td>sub failure</td>
    <td>Always fails.</td>
    <td></td>
    <td>An empty list.</td>
  </tr>
  <tr>
    <td>Combinators</td>
    <td>proto sequence(|)</td>
    <td>Sequences multiple parsers.</td>
    <td></td>
    <td>Variants: multi sub sequence(&p): Single parser. multi sub sequence(&p1, &p2): Two parsers. multi sub sequence(*@args): Multiple parsers.</td>
  </tr>
  <tr>
    <td>Combinators</td>
    <td>sub infix:<«&»>( *@args )</td>
    <td>Infix operator for sequencing parsers.</td>
    <td></td>
    <td>A sequence of parsers.</td>
  </tr>
  <tr>
    <td>Combinators</td>
    <td>sub infix:<(&)>( *@args )</td>
    <td>Infix operator for sequencing parsers.</td>
    <td></td>
    <td>A sequence of parsers.</td>
  </tr>
  <tr>
    <td>Combinators</td>
    <td>sub infix:<⨂>( *@args )</td>
    <td>Infix operator for sequencing parsers.</td>
    <td></td>
    <td>A sequence of parsers.</td>
  </tr>
  <tr>
    <td>Combinators</td>
    <td>sub alternatives(*@args)</td>
    <td>Tries multiple parsers, succeeding with the first match.</td>
    <td></td>
    <td>A callable that attempts each parser in sequence.</td>
  </tr>
  <tr>
    <td>Combinators</td>
    <td>sub infix:<«|»>( *@args )</td>
    <td>Infix operator for alternatives.</td>
    <td></td>
    <td>A choice between parsers.</td>
  </tr>
  <tr>
    <td>Combinators</td>
    <td>sub infix:<(|)>( *@args )</td>
    <td>Infix operator for alternatives.</td>
    <td></td>
    <td>A choice between parsers.</td>
  </tr>
  <tr>
    <td>Combinators</td>
    <td>sub infix:<⨁>( *@args )</td>
    <td>Infix operator for alternatives.</td>
    <td></td>
    <td>A choice between parsers.</td>
  </tr>
  <tr>
    <td>Combinators</td>
    <td>sub alternatives-first-match(*@args)</td>
    <td>Tries multiple parsers, succeeding with the first match that consumes input.</td>
    <td></td>
    <td>A callable that attempts each parser in sequence.</td>
  </tr>
  <tr>
    <td>Combinators</td>
    <td>sub infix:<«||»>( *@args )</td>
    <td>Infix operator for first-match alternatives.</td>
    <td></td>
    <td>A choice between parsers.</td>
  </tr>
  <tr>
    <td>Combinators</td>
    <td>sub infix:<(||)>( *@args )</td>
    <td>Infix operator for first-match alternatives.</td>
    <td></td>
    <td>A choice between parsers.</td>
  </tr>
  <tr>
    <td>Combinators</td>
    <td>sub infix:<⨁⨁>( *@args )</td>
    <td>Infix operator for first-match alternatives.</td>
    <td></td>
    <td>A choice between parsers.</td>
  </tr>
  <tr>
    <td>Next Combinators</td>
    <td>sub drop-spaces(&p)</td>
    <td>Drops leading spaces before applying a parser.</td>
    <td>&p: The parser to apply.</td>
    <td>A callable that skips spaces.</td>
  </tr>
  <tr>
    <td>Next Combinators</td>
    <td>sub just(&p)</td>
    <td>Applies a parser and succeeds only if all input is consumed.</td>
    <td>&p: The parser to apply.</td>
    <td>A callable that ensures complete consumption.</td>
  </tr>
  <tr>
    <td>Next Combinators</td>
    <td>sub some(&p)</td>
    <td>Applies a parser and returns the result if successful.</td>
    <td>&p: The parser to apply.</td>
    <td>The result of the parser.</td>
  </tr>
  <tr>
    <td>Next Combinators</td>
    <td>sub shortest(&p)</td>
    <td>Returns the shortest successful parse.</td>
    <td>&p: The parser to apply.</td>
    <td>The shortest parse result.</td>
  </tr>
  <tr>
    <td>Next Combinators</td>
    <td>sub apply(&f, &p)</td>
    <td>Applies a function to the result of a parser.</td>
    <td>&f: The function to apply. &p: The parser to apply.</td>
    <td>A callable that applies the function to the parser result.</td>
  </tr>
  <tr>
    <td>Next Combinators</td>
    <td>sub infix:<«o>( &p, &f )</td>
    <td>Infix operator for applying a function to a parser result.</td>
    <td></td>
    <td>A callable that applies the function.</td>
  </tr>
  <tr>
    <td>Next Combinators</td>
    <td>sub infix:<(^)>( &p, &f )</td>
    <td>Infix operator for applying a function to a parser result.</td>
    <td></td>
    <td>A callable that applies the function.</td>
  </tr>
  <tr>
    <td>Next Combinators</td>
    <td>sub infix:<⨀>( &f, &p )</td>
    <td>Infix operator for applying a function to a parser result.</td>
    <td></td>
    <td>A callable that applies the function.</td>
  </tr>
  <tr>
    <td>Next Combinators</td>
    <td>sub sequence-pick-left(&p1, &p2)</td>
    <td>Sequences two parsers, returning the result of the first.</td>
    <td>&p1: The first parser. &p2: The second parser.</td>
    <td>The result of the first parser.</td>
  </tr>
  <tr>
    <td>Next Combinators</td>
    <td>sub infix:<«&>( &p1, &p2 )</td>
    <td>Infix operator for sequence-pick-left.</td>
    <td></td>
    <td>The result of the first parser.</td>
  </tr>
  <tr>
    <td>Next Combinators</td>
    <td>sub infix:<(\<&)>( &p1, &p2 )</td>
    <td>Infix operator for sequence-pick-left.</td>
    <td></td>
    <td>The result of the first parser.</td>
  </tr>
  <tr>
    <td>Next Combinators</td>
    <td>sub infix:<◁>( &p1, &p2 )</td>
    <td>Infix operator for sequence-pick-left.</td>
    <td></td>
    <td>The result of the first parser.</td>
  </tr>
  <tr>
    <td>Next Combinators</td>
    <td>sub sequence-pick-right(&p1, &p2)</td>
    <td>Sequences two parsers, returning the result of the second.</td>
    <td>&p1: The first parser. &p2: The second parser.</td>
    <td>The result of the second parser.</td>
  </tr>
  <tr>
    <td>Next Combinators</td>
    <td>sub infix:<\&\>>( &p1, &p2 )</td>
    <td>Infix operator for sequence-pick-right.</td>
    <td></td>
    <td>The result of the second parser.</td>
  </tr>
  <tr>
    <td>Next Combinators</td>
    <td>sub infix:<(&»)>( &p1, &p2 )</td>
    <td>Infix operator for sequence-pick-right.</td>
    <td></td>
    <td>The result of the second parser.</td>
  </tr>
  <tr>
    <td>Next Combinators</td>
    <td>sub infix:<▷>( &p1, &p2 )</td>
    <td>Infix operator for sequence-pick-right.</td>
    <td></td>
    <td>The result of the second parser.</td>
  </tr>
  <tr>
    <td>Second Next Combinators</td>
    <td>sub pack(&s1, &p, &s2)</td>
    <td>Parses with surrounding symbols.</td>
    <td>&s1: The starting symbol parser. &p: The main parser. &s2: The ending symbol parser.</td>
    <td>The result of the main parser.</td>
  </tr>
  <tr>
    <td>Second Next Combinators</td>
    <td>sub parenthesized(&p)</td>
    <td>Parses a parenthesized expression.</td>
    <td>&p: The parser for the expression.</td>
    <td>The result of the expression parser.</td>
  </tr>
  <tr>
    <td>Second Next Combinators</td>
    <td>sub bracketed(&p)</td>
    <td>Parses a bracketed expression.</td>
    <td>&p: The parser for the expression.</td>
    <td>The result of the expression parser.</td>
  </tr>
  <tr>
    <td>Second Next Combinators</td>
    <td>sub curly-bracketed(&p)</td>
    <td>Parses a curly bracketed expression.</td>
    <td>&p: The parser for the expression.</td>
    <td>The result of the expression parser.</td>
  </tr>
  <tr>
    <td>Second Next Combinators</td>
    <td>sub option(&p)</td>
    <td>Parses an optional element.</td>
    <td>&p: The parser for the optional element.</td>
    <td>The result of the parser or an empty result.</td>
  </tr>
  <tr>
    <td>Second Next Combinators</td>
    <td>sub many(&p)</td>
    <td>Parses zero or more occurrences of an element.</td>
    <td>&p: The parser for the element.</td>
    <td>A list of results.</td>
  </tr>
  <tr>
    <td>Second Next Combinators</td>
    <td>sub many1(&p)</td>
    <td>Parses one or more occurrences of an element.</td>
    <td>&p: The parser for the element.</td>
    <td>A list of results.</td>
  </tr>
  <tr>
    <td>Second Next Combinators</td>
    <td>sub list-of(&p, &sep)</td>
    <td>Parses a list of elements separated by a separator.</td>
    <td>&p: The parser for the elements. &sep: The parser for the separator.</td>
    <td>A list of results.</td>
  </tr>
  <tr>
    <td>Second Next Combinators</td>
    <td>sub chain-left(&p, &sep)</td>
    <td>Parses a left-associative chain of operations.</td>
    <td>&p: The parser for the operands. &sep: The parser for the operators.</td>
    <td>The result of the chain.</td>
  </tr>
  <tr>
    <td>Second Next Combinators</td>
    <td>sub chain-right(&p, &sep)</td>
    <td>Parses a right-associative chain of operations.</td>
    <td>&p: The parser for the operands. &sep: The parser for the operators.</td>
    <td>The result of the chain.</td>
  </tr>
  <tr>
    <td>Backtracking Related</td>
    <td>sub take-first(&p)</td>
    <td>Takes the first successful parse.</td>
    <td>&p: The parser to apply.</td>
    <td>The first successful result.</td>
  </tr>
  <tr>
    <td>Backtracking Related</td>
    <td>sub greedy(&p)</td>
    <td>Parses as many elements as possible.</td>
    <td>&p: The parser for the elements.</td>
    <td>The result of the greedy parse.</td>
  </tr>
  <tr>
    <td>Backtracking Related</td>
    <td>sub greedy1(&p)</td>
    <td>Parses as many elements as possible, requiring at least one.</td>
    <td>&p: The parser for the elements.</td>
    <td>The result of the greedy parse.</td>
  </tr>
  <tr>
    <td>Backtracking Related</td>
    <td>sub compulsion(&p)</td>
    <td>Parses an element compulsorily.</td>
    <td>&p: The parser for the element.</td>
    <td>The result of the parser.</td>
  </tr>
  <tr>
    <td>Extra Parsers</td>
    <td>constant &pInteger</td>
    <td>Parses an integer.</td>
    <td></td>
    <td>The integer value.</td>
  </tr>
  <tr>
    <td>Extra Parsers</td>
    <td>constant &pNumber</td>
    <td>Parses a number.</td>
    <td></td>
    <td>The numerical value.</td>
  </tr>
  <tr>
    <td>Extra Parsers</td>
    <td>constant &pWord</td>
    <td>Parses a word.</td>
    <td></td>
    <td>The word as a string.</td>
  </tr>
  <tr>
    <td>Extra Parsers</td>
    <td>constant &pLetterWord</td>
    <td>Parses a word consisting of letters.</td>
    <td></td>
    <td>The word as a string.</td>
  </tr>
  <tr>
    <td>Extra Parsers</td>
    <td>constant &pIdentifier</td>
    <td>Parses an identifier.</td>
    <td></td>
    <td>The identifier as a string.</td>
  </tr>
  <tr>
    <td>Shortcuts</td>
    <td>constant &sp</td>
    <td>Shortcut for drop-spaces.</td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>Shortcuts</td>
    <td>constant &seq</td>
    <td>Shortcut for sequence.</td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>Shortcuts</td>
    <td>constant &seql</td>
    <td>Shortcut for sequence-pick-left.</td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>Shortcuts</td>
    <td>constant &seqr</td>
    <td>Shortcut for sequence-pick-right.</td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>Shortcuts</td>
    <td>constant &and</td>
    <td>Shortcut for sequence.</td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>Shortcuts</td>
    <td>constant &andl</td>
    <td>Shortcut for sequence-pick-left.</td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>Shortcuts</td>
    <td>constant &andr</td>
    <td>Shortcut for sequence-pick-right.</td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>Shortcuts</td>
    <td>constant &alt</td>
    <td>Shortcut for alternatives.</td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>Shortcuts</td>
    <td>constant &or</td>
    <td>Shortcut for alternatives.</td>
    <td></td>
    <td></td>
  </tr>
</table>

-----

The HTML table above was LLM-generated using the file ["Parsers-documentation.md](./Parsers-documentation.md).
That file was generated from the source code file ["FunctionalParsers.rakumod"](../lib/FunctionalParsers.rakumod).

Here is the Raku code used:


```raku
use LLM::Funcitons;
use LLM::Prompts;
use Data::Importers;

my $conf4o = llm-configuration('ChatGPT', model => 'gpt-4o', max-tokens => 8192, temperature => 0.4);
```


```raku
my $fileName = '../lib/FunctionalParsers.rakumod';
my $code = data-import($fileName);

text-stats($code)
```

```raku
my $res = llm-synthesize([
    "You are an expert of the Raku programming language.",
    "You are also an expert of programming and using functional parsers AKA parser combinators.",
    "Generate the documentation of the subs and callable constants in this Raku module code:\n",
    "CODE BEGIN:",
    $code,
    "CODE END",
    llm-prompt('NothingElse')('Markdown')
], e => $conf4o);

text-stats($res)
```

```raku
my $tbl = llm-synthesize([
    "Turn the following Markdown document into an HTML table with the following columns:",
    "\tType, Symbol, Description, Parameters, Returns",
    "The section names should be in the column 'Type'.",
    $res,
    llm-prompt('NothingElse')('HTML')
], e => $conf4o)
```