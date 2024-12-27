# FunctionalParsers Module Documentation

-------

## Basic Parsers

### `sub symbol(Str $a)`

- **Description**: Parses a single symbol.
- **Parameters**:
    - `$a`: The symbol to match.
- **Returns**: A callable that attempts to match the symbol.

### `sub token(Str $k)`

- **Description**: Parses a sequence of characters (token).
- **Parameters**:
    - `$k`: The token to match.
- **Returns**: A callable that attempts to match the token.

### `sub satisfy(&pred)`

- **Description**: Parses a single element that satisfies a predicate.
- **Parameters**:
    - `&pred`: A predicate function to satisfy.
- **Returns**: A callable that attempts to match an element satisfying the predicate.

### `sub epsilon()`

- **Description**: Always succeeds without consuming any input.
- **Returns**: A callable that always succeeds.

### `proto sub success(|)`

- **Description**: Always succeeds, optionally returning a value.
- **Variants**:
    - `multi sub success()`: Succeeds with no value.
    - `multi sub success($v)`: Succeeds with a value `$v`.

### `sub failure`

- **Description**: Always fails.
- **Returns**: An empty list.

-------

## Combinators

### `proto sequence(|)`

- **Description**: Sequences multiple parsers.
- **Variants**:
    - `multi sub sequence(&p)`: Single parser.
    - `multi sub sequence(&p1, &p2)`: Two parsers.
    - `multi sub sequence(*@args)`: Multiple parsers.

### `sub infix:<«&»>( *@args )`

- **Description**: Infix operator for sequencing parsers.
- **Returns**: A sequence of parsers.

### `sub infix:<(&)>( *@args )`

- **Description**: Infix operator for sequencing parsers.
- **Returns**: A sequence of parsers.

### `sub infix:<⨂>( *@args )`

- **Description**: Infix operator for sequencing parsers.
- **Returns**: A sequence of parsers.

### `sub alternatives(*@args)`

- **Description**: Tries multiple parsers, succeeding with the first match.
- **Returns**: A callable that attempts each parser in sequence.

### `sub infix:<«|»>( *@args )`

- **Description**: Infix operator for alternatives.
- **Returns**: A choice between parsers.

### `sub infix:<(|)>( *@args )`

- **Description**: Infix operator for alternatives.
- **Returns**: A choice between parsers.

### `sub infix:<⨁>( *@args )`

- **Description**: Infix operator for alternatives.
- **Returns**: A choice between parsers.

### `sub alternatives-first-match(*@args)`

- **Description**: Tries multiple parsers, succeeding with the first match that consumes input.
- **Returns**: A callable that attempts each parser in sequence.

### `sub infix:<«||»>( *@args )`

- **Description**: Infix operator for first-match alternatives.
- **Returns**: A choice between parsers.

### `sub infix:<(||)>( *@args )`

- **Description**: Infix operator for first-match alternatives.
- **Returns**: A choice between parsers.

### `sub infix:<⨁⨁>( *@args )`

- **Description**: Infix operator for first-match alternatives.
- **Returns**: A choice between parsers.

## Next Combinators

### `sub drop-spaces(&p)`

- **Description**: Drops leading spaces before applying a parser.
- **Parameters**:
    - `&p`: The parser to apply.
- **Returns**: A callable that skips spaces.

### `sub just(&p)`

- **Description**: Applies a parser and succeeds only if all input is consumed.
- **Parameters**:
    - `&p`: The parser to apply.
- **Returns**: A callable that ensures complete consumption.

### `sub some(&p)`

- **Description**: Applies a parser and returns the result if successful.
- **Parameters**:
    - `&p`: The parser to apply.
- **Returns**: The result of the parser.

### `sub shortest(&p)`

- **Description**: Returns the shortest successful parse.
- **Parameters**:
    - `&p`: The parser to apply.
- **Returns**: The shortest parse result.

### `sub apply(&f, &p)`

- **Description**: Applies a function to the result of a parser.
- **Parameters**:
    - `&f`: The function to apply.
    - `&p`: The parser to apply.
- **Returns**: A callable that applies the function to the parser result.

### `sub infix:<«o>( &p, &f )`

- **Description**: Infix operator for applying a function to a parser result.
- **Returns**: A callable that applies the function.

### `sub infix:<(^)>( &p, &f )`

- **Description**: Infix operator for applying a function to a parser result.
- **Returns**: A callable that applies the function.

### `sub infix:<⨀>( &f, &p )`

- **Description**: Infix operator for applying a function to a parser result.
- **Returns**: A callable that applies the function.

### `sub sequence-pick-left(&p1, &p2)`

- **Description**: Sequences two parsers, returning the result of the first.
- **Parameters**:
    - `&p1`: The first parser.
    - `&p2`: The second parser.
- **Returns**: The result of the first parser.

### `sub infix:<«&>( &p1, &p2 )`

- **Description**: Infix operator for sequence-pick-left.
- **Returns**: The result of the first parser.

### `sub infix:<(\<&)>( &p1, &p2 )`

- **Description**: Infix operator for sequence-pick-left.
- **Returns**: The result of the first parser.

### `sub infix:<◁>( &p1, &p2 )`

- **Description**: Infix operator for sequence-pick-left.
- **Returns**: The result of the first parser.

### `sub sequence-pick-right(&p1, &p2)`

- **Description**: Sequences two parsers, returning the result of the second.
- **Parameters**:
    - `&p1`: The first parser.
    - `&p2`: The second parser.
- **Returns**: The result of the second parser.

### `sub infix:<\&\>>( &p1, &p2 )`

- **Description**: Infix operator for sequence-pick-right.
- **Returns**: The result of the second parser.

### `sub infix:<(&»)>( &p1, &p2 )`

- **Description**: Infix operator for sequence-pick-right.
- **Returns**: The result of the second parser.

### `sub infix:<▷>( &p1, &p2 )`

- **Description**: Infix operator for sequence-pick-right.
- **Returns**: The result of the second parser.

-------

## Second Next Combinators

### `sub pack(&s1, &p, &s2)`

- **Description**: Parses with surrounding symbols.
- **Parameters**:
    - `&s1`: The starting symbol parser.
    - `&p`: The main parser.
    - `&s2`: The ending symbol parser.
- **Returns**: The result of the main parser.

### `sub parenthesized(&p)`

- **Description**: Parses a parenthesized expression.
- **Parameters**:
    - `&p`: The parser for the expression.
- **Returns**: The result of the expression parser.

### `sub bracketed(&p)`

- **Description**: Parses a bracketed expression.
- **Parameters**:
    - `&p`: The parser for the expression.
- **Returns**: The result of the expression parser.

### `sub curly-bracketed(&p)`

- **Description**: Parses a curly bracketed expression.
- **Parameters**:
    - `&p`: The parser for the expression.
- **Returns**: The result of the expression parser.

### `sub option(&p)`

- **Description**: Parses an optional element.
- **Parameters**:
    - `&p`: The parser for the optional element.
- **Returns**: The result of the parser or an empty result.

### `sub many(&p)`

- **Description**: Parses zero or more occurrences of an element.
- **Parameters**:
    - `&p`: The parser for the element.
- **Returns**: A list of results.

### `sub many1(&p)`

- **Description**: Parses one or more occurrences of an element.
- **Parameters**:
    - `&p`: The parser for the element.
- **Returns**: A list of results.

### `sub list-of(&p, &sep)`

- **Description**: Parses a list of elements separated by a separator.
- **Parameters**:
    - `&p`: The parser for the elements.
    - `&sep`: The parser for the separator.
- **Returns**: A list of results.

### `sub chain-left(&p, &sep)`

- **Description**: Parses a left-associative chain of operations.
- **Parameters**:
    - `&p`: The parser for the operands.
    - `&sep`: The parser for the operators.
- **Returns**: The result of the chain.

### `sub chain-right(&p, &sep)`

- **Description**: Parses a right-associative chain of operations.
- **Parameters**:
    - `&p`: The parser for the operands.
    - `&sep`: The parser for the operators.
- **Returns**: The result of the chain.

------

## Backtracking Related

### `sub take-first(&p)`

- **Description**: Takes the first successful parse.
- **Parameters**:
    - `&p`: The parser to apply.
- **Returns**: The first successful result.

### `sub greedy(&p)`

- **Description**: Parses as many elements as possible.
- **Parameters**:
    - `&p`: The parser for the elements.
- **Returns**: The result of the greedy parse.

### `sub greedy1(&p)`

- **Description**: Parses as many elements as possible, requiring at least one.
- **Parameters**:
    - `&p`: The parser for the elements.
- **Returns**: The result of the greedy parse.

### `sub compulsion(&p)`

- **Description**: Parses an element compulsorily.
- **Parameters**:
    - `&p`: The parser for the element.
- **Returns**: The result of the parser.

------

## Extra Parsers

### `constant &pInteger`

- **Description**: Parses an integer.
- **Returns**: The integer value.

### `constant &pNumber`

- **Description**: Parses a number.
- **Returns**: The numerical value.

### `constant &pWord`

- **Description**: Parses a word.
- **Returns**: The word as a string.

### `constant &pLetterWord`

- **Description**: Parses a word consisting of letters.
- **Returns**: The word as a string.

### `constant &pIdentifier`

- **Description**: Parses an identifier.
- **Returns**: The identifier as a string.

-------

## Shortcuts

### `constant &sp`

- **Description**: Shortcut for `drop-spaces`.

### `constant &seq`

- **Description**: Shortcut for `sequence`.

### `constant &seql`

- **Description**: Shortcut for `sequence-pick-left`.

### `constant &seqr`

- **Description**: Shortcut for `sequence-pick-right`.

### `constant &and`

- **Description**: Shortcut for `sequence`.

### `constant &andl`

- **Description**: Shortcut for `sequence-pick-left`.

### `constant &andr`

- **Description**: Shortcut for `sequence-pick-right`.

### `constant &alt`

- **Description**: Shortcut for `alternatives`.

### `constant &or`

- **Description**: Shortcut for `alternatives`.