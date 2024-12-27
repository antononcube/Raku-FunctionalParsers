
## Functional parsers

<table border="1">
  <tr>
    <th>Type</th>
    <th>Symbol</th>
    <th>Description</th>
    <th>Parameters</th>
    <th>Returns</th>
  </tr>
  <tr>
    <td rowspan="6">Basic Parsers</td>
    <td><strong>symbol</strong>(Str $a)</td>
    <td>Parses a single symbol.</td>
    <td>$a: The symbol to match.</td>
    <td>A callable that attempts to match the symbol.</td>
  </tr>
  <tr>
    <td><strong>token</strong>(Str $k)</td>
    <td>Parses a sequence of characters (token).</td>
    <td>$k: The token to match.</td>
    <td>A callable that attempts to match the token.</td>
  </tr>
  <tr>
    <td><strong>satisfy</strong>(&pred)</td>
    <td>Parses a single element that satisfies a predicate.</td>
    <td>&pred: A predicate function to satisfy.</td>
    <td>A callable that attempts to match an element satisfying the predicate.</td>
  </tr>
  <tr>
    <td><strong>epsilon</strong>()</td>
    <td>Always succeeds without consuming any input.</td>
    <td></td>
    <td>A callable that always succeeds.</td>
  </tr>
  <tr>
    <td><strong>success</strong>(|)</td>
    <td>Always succeeds, optionally returning a value.</td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td><strong>failure</strong></td>
    <td>Always fails.</td>
    <td></td>
    <td>An empty list.</td>
  </tr>
  <tr>
    <td rowspan="11">Combinators</td>
    <td><strong>sequence</strong>(|)</td>
    <td>Sequences multiple parsers.</td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td><strong>infix:<«&»></strong>( *@args )</td>
    <td>Infix operator for sequencing parsers.</td>
    <td></td>
    <td>A sequence of parsers.</td>
  </tr>
  <tr>
    <td><strong>infix:<(&)></strong>( *@args )</td>
    <td>Infix operator for sequencing parsers.</td>
    <td></td>
    <td>A sequence of parsers.</td>
  </tr>
  <tr>
    <td><strong>infix:<⨂></strong>( *@args )</td>
    <td>Infix operator for sequencing parsers.</td>
    <td></td>
    <td>A sequence of parsers.</td>
  </tr>
  <tr>
    <td><strong>alternatives</strong>(* @args)</td>
    <td>Tries multiple parsers, succeeding with the first match.</td>
    <td></td>
    <td>A callable that attempts each parser in sequence.</td>
  </tr>
  <tr>
    <td><strong>infix:<«|»></strong>( *@args )</td>
    <td>Infix operator for alternatives.</td>
    <td></td>
    <td>A choice between parsers.</td>
  </tr>
  <tr>
    <td><strong>infix:<(|)></strong>( *@args )</td>
    <td>Infix operator for alternatives.</td>
    <td></td>
    <td>A choice between parsers.</td>
  </tr>
  <tr>
    <td><strong>infix:<⨁></strong>( *@args )</td>
    <td>Infix operator for alternatives.</td>
    <td></td>
    <td>A choice between parsers.</td>
  </tr>
  <tr>
    <td><strong>alternatives-first-match</strong>(* @args)</td>
    <td>Tries multiple parsers, succeeding with the first match that consumes input.</td>
    <td></td>
    <td>A callable that attempts each parser in sequence.</td>
  </tr>
  <tr>
    <td><strong>infix:<«||»></strong>( *@args )</td>
    <td>Infix operator for first-match alternatives.</td>
    <td></td>
    <td>A choice between parsers.</td>
  </tr>
  <tr>
    <td><strong>infix:<(||)></strong>( *@args )</td>
    <td>Infix operator for first-match alternatives.</td>
    <td></td>
    <td>A choice between parsers.</td>
  </tr>
  <tr>
    <td rowspan="16">Next Combinators</td>
    <td><strong>drop-spaces</strong>(&p)</td>
    <td>Drops leading spaces before applying a parser.</td>
    <td>&p: The parser to apply.</td>
    <td>A callable that skips spaces.</td>
  </tr>
  <tr>
    <td><strong>just</strong>(&p)</td>
    <td>Applies a parser and succeeds only if all input is consumed.</td>
    <td>&p: The parser to apply.</td>
    <td>A callable that ensures complete consumption.</td>
  </tr>
  <tr>
    <td><strong>some</strong>(&p)</td>
    <td>Applies a parser and returns the result if successful.</td>
    <td>&p: The parser to apply.</td>
    <td>The result of the parser.</td>
  </tr>
  <tr>
    <td><strong>shortest</strong>(&p)</td>
    <td>Returns the shortest successful parse.</td>
    <td>&p: The parser to apply.</td>
    <td>The shortest parse result.</td>
  </tr>
  <tr>
    <td><strong>apply</strong>(&f, &p)</td>
    <td>Applies a function to the result of a parser.</td>
    <td>&f: The function to apply.<br>&p: The parser to apply.</td>
    <td>A callable that applies the function to the parser result.</td>
  </tr>
  <tr>
    <td><strong>infix:<«o></strong>( &p, &f )</td>
    <td>Infix operator for applying a function to a parser result.</td>
    <td></td>
    <td>A callable that applies the function.</td>
  </tr>
  <tr>
    <td><strong>infix:<(^)></strong>( &p, &f )</td>
    <td>Infix operator for applying a function to a parser result.</td>
    <td></td>
    <td>A callable that applies the function.</td>
  </tr>
  <tr>
    <td><strong>infix:<⨀></strong>( &f, &p )</td>
    <td>Infix operator for applying a function to a parser result.</td>
    <td></td>
    <td>A callable that applies the function.</td>
  </tr>
  <tr>
    <td><strong>sequence-pick-left</strong>(&p1, &p2)</td>
    <td>Sequences two parsers, returning the result of the first.</td>
    <td>&p1: The first parser.<br>&p2: The second parser.</td>
    <td>The result of the first parser.</td>
  </tr>
  <tr>
    <td><strong>infix:<«&></strong>( &p1, &p2 )</td>
    <td>Infix operator for sequence-pick-left.</td>
    <td></td>
    <td>The result of the first parser.</td>
  </tr>
  <tr>
    <td><strong>infix:<(\<&)></strong>( &p1, &p2 )</td>
    <td>Infix operator for sequence-pick-left.</td>
    <td></td>
    <td>The result of the first parser.</td>
  </tr>
  <tr>
    <td><strong>infix:<◁></strong>( &p1, &p2 )</td>
    <td>Infix operator for sequence-pick-left.</td>
    <td></td>
    <td>The result of the first parser.</td>
  </tr>
  <tr>
    <td><strong>sequence-pick-right</strong>(&p1, &p2)</td>
    <td>Sequences two parsers, returning the result of the second.</td>
    <td>&p1: The first parser.<br>&p2: The second parser.</td>
    <td>The result of the second parser.</td>
  </tr>
  <tr>
    <td><strong>infix:<\&\>></strong>( &p1, &p2 )</td>
    <td>Infix operator for sequence-pick-right.</td>
    <td></td>
    <td>The result of the second parser.</td>
  </tr>
  <tr>
    <td><strong>infix:<(&»)></strong>( &p1, &p2 )</td>
    <td>Infix operator for sequence-pick-right.</td>
    <td></td>
    <td>The result of the second parser.</td>
  </tr>
  <tr>
    <td><strong>infix:<▷></strong>( &p1, &p2 )</td>
    <td>Infix operator for sequence-pick-right.</td>
    <td></td>
    <td>The result of the second parser.</td>
  </tr>
  <tr>
    <td rowspan="10">Second Next Combinators</td>
    <td><strong>pack</strong>(&s1, &p, &s2)</td>
    <td>Parses with surrounding symbols.</td>
    <td>&s1: The starting symbol parser.<br>&p: The main parser.<br>&s2: The ending symbol parser.</td>
    <td>The result of the main parser.</td>
  </tr>
  <tr>
    <td><strong>parenthesized</strong>(&p)</td>
    <td>Parses a parenthesized expression.</td>
    <td>&p: The parser for the expression.</td>
    <td>The result of the expression parser.</td>
  </tr>
  <tr>
    <td><strong>bracketed</strong>(&p)</td>
    <td>Parses a bracketed expression.</td>
    <td>&p: The parser for the expression.</td>
    <td>The result of the expression parser.</td>
  </tr>
  <tr>
    <td><strong>curly-bracketed</strong>(&p)</td>
    <td>Parses a curly bracketed expression.</td>
    <td>&p: The parser for the expression.</td>
    <td>The result of the expression parser.</td>
  </tr>
  <tr>
    <td><strong>option</strong>(&p)</td>
    <td>Parses an optional element.</td>
    <td>&p: The parser for the optional element.</td>
    <td>The result of the parser or an empty result.</td>
  </tr>
  <tr>
    <td><strong>many</strong>(&p)</td>
    <td>Parses zero or more occurrences of an element.</td>
    <td>&p: The parser for the element.</td>
    <td>A list of results.</td>
  </tr>
  <tr>
    <td><strong>many1</strong>(&p)</td>
    <td>Parses one or more occurrences of an element.</td>
    <td>&p: The parser for the element.</td>
    <td>A list of results.</td>
  </tr>
  <tr>
    <td><strong>list-of</strong>(&p, &sep)</td>
    <td>Parses a list of elements separated by a separator.</td>
    <td>&p: The parser for the elements.<br>&sep: The parser for the separator.</td>
    <td>A list of results.</td>
  </tr>
  <tr>
    <td><strong>chain-left</strong>(&p, &sep)</td>
    <td>Parses a left-associative chain of operations.</td>
    <td>&p: The parser for the operands.<br>&sep: The parser for the operators.</td>
    <td>The result of the chain.</td>
  </tr>
  <tr>
    <td><strong>chain-right</strong>(&p, &sep)</td>
    <td>Parses a right-associative chain of operations.</td>
    <td>&p: The parser for the operands.<br>&sep: The parser for the operators.</td>
    <td>The result of the chain.</td>
  </tr>
  <tr>
    <td rowspan="4">Backtracking Related</td>
    <td><strong>take-first</strong>(&p)</td>
    <td>Takes the first successful parse.</td>
    <td>&p: The parser to apply.</td>
    <td>The first successful result.</td>
  </tr>
  <tr>
    <td><strong>greedy</strong>(&p)</td>
    <td>Parses as many elements as possible.</td>
    <td>&p: The parser for the elements.</td>
    <td>The result of the greedy parse.</td>
  </tr>
  <tr>
    <td><strong>greedy1</strong>(&p)</td>
    <td>Parses as many elements as possible, requiring at least one.</td>
    <td>&p: The parser for the elements.</td>
    <td>The result of the greedy parse.</td>
  </tr>
  <tr>
    <td><strong>compulsion</strong>(&p)</td>
    <td>Parses an element compulsorily.</td>
    <td>&p: The parser for the element.</td>
    <td>The result of the parser.</td>
  </tr>
  <tr>
    <td rowspan="5">Extra Parsers</td>
    <td><strong>pInteger</strong></td>
    <td>Parses an integer.</td>
    <td></td>
    <td>The integer value.</td>
  </tr>
  <tr>
    <td><strong>pNumber</strong></td>
    <td>Parses a number.</td>
    <td></td>
    <td>The numerical value.</td>
  </tr>
  <tr>
    <td><strong>pWord</strong></td>
    <td>Parses a word.</td>
    <td></td>
    <td>The word as a string.</td>
  </tr>
  <tr>
    <td><strong>pLetterWord</strong></td>
    <td>Parses a word consisting of letters.</td>
    <td></td>
    <td>The word as a string.</td>
  </tr>
  <tr>
    <td><strong>pIdentifier</strong></td>
    <td>Parses an identifier.</td>
    <td></td>
    <td>The identifier as a string.</td>
  </tr>
  <tr>
    <td rowspan="9">Shortcuts</td>
    <td><strong>sp</strong></td>
    <td>Shortcut for <strong>drop-spaces</strong>.</td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td><strong>seq</strong></td>
    <td>Shortcut for <strong>sequence</strong>.</td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td><strong>seql</strong></td>
    <td>Shortcut for <strong>sequence-pick-left</strong>.</td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td><strong>seqr</strong></td>
    <td>Shortcut for <strong>sequence-pick-right</strong>.</td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td><strong>and</strong></td>
    <td>Shortcut for <strong>sequence</strong>.</td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td><strong>andl</strong></td>
    <td>Shortcut for <strong>sequence-pick-left</strong>.</td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td><strong>andr</strong></td>
    <td>Shortcut for <strong>sequence-pick-right</strong>.</td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td><strong>alt</strong></td>
    <td>Shortcut for <strong>alternatives</strong>.</td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td><strong>or</strong></td>
    <td>Shortcut for <strong>alternatives</strong>.</td>
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

```
# (chars => 9092 words => 1154 lines => 324)
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

```
# (chars => 9923 words => 1403 lines => 379)
```

```raku
my $tbl = llm-synthesize([
    "Turn the following Markdown document into an HTML table with the following columns:",
    "\tType, Symbol, Description, Parameters, Returns",
    "The section names should be in the column 'Type'.",
    "Separate the table into sections corresponding to the 'Type' values.",
    "Within each table section say the 'Type' value only once.",
    "Put the callable or sub names into bold. The names only, not the keywords `sub` and `constant`, or signature arguments.",
    "Please, make sure the columns are properly aligned.",
    $res,
    llm-prompt('NothingElse')('HTML')
],
e => $conf4o);

text-stats($tbl)
```

```
# (chars => 11706 words => 1090 lines => 384)
```