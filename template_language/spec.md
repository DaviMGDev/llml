Here is the formal specification for your templating language, structured and formatted to match the style of the example you provided.

***

# Templating Language Specification (Draft)

## 1. Philosophy

The language is designed to be a minimalist, text-first templating engine. 

The core philosophy is "text outside is text inside". The language avoids complex scoping, strict static typing, and "magic" variables. It is intended to generate code, HTML, SQL, or any arbitrary text with high readability and explicit behavior.

The syntax exists to:
* Keep the parser simple and fast.
* Make the template source code highly readable.
* Prevent accidental whitespace/indentation corruption in the output.
* Enforce explicit variable and macro usage.

---

## 2. Comments

Single-line comments:

```txt
// this is a comment
```

Multi-line comments:

```txt
/*
this is a comment
that spans multiple lines
*/
```

Comments are stripped during compilation and do not appear in the output.

---

## 3. Lexical Structure and Keywords

All language directives and keywords must be prefixed with a period (`.`). 

```txt
.var
.const
.if
.for
.macro
.import
```

Text that is not part of a directive, interpolation block, or macro definition is treated as **Raw Text**. Raw text is copied verbatim to the output file, preserving all spaces, tabs, and newlines.

Quotes (`"`) outside of code blocks are treated as literal characters and printed as-is.

---

## 4. Variables and Constants

Variables and constants are declared using `.var` and `.const`. Types are strictly inferred by the compiler; explicit type declarations are not permitted.

### Variables

Syntax:

```txt
.var name = value;
```

Example:

```txt
.var x = 10;
.var y = 0.001;
.var s = "hello world";
```

*Note: The assignment operator `=` and the terminating semicolon `;` are required.*

### Constants

Syntax:

```txt
.const name = value;
```

Example:

```txt
.const pi = 3.14159;
```

Constants cannot be reassigned after declaration.

---

## 5. Interpolation and Expressions

Expressions are evaluated and printed to the output using the `${ ... }` syntax.

Syntax:

```txt
${ expression }
```

Example:

```txt
pi is approximately ${pi}
The sum is ${x + y}
```

Expressions support:
* Arithmetic operators: `+`, `-`, `*`, `/`, `%`
* Comparison operators: `==`, `!=`, `<`, `>`, `<=`, `>=`
* Logical operators: `&&`, `||`, `!`
* Built-in method calls (e.g., string manipulation).

Example of built-in methods:

```txt
${ "hello".upper() }       // Outputs: HELLO
${ "a,b,c".split(",") }    // Outputs a list/array
```

---

## 6. Control Flow

Control flow directives dictate whether and how many times a block of template text is rendered.

### Conditionals

Syntax:

```txt
.if condition {
    // rendered if true
}
.else if condition {
    // rendered if true
}
.else {
    // rendered if all above are false
}
```

Example:

```txt
.if x > 5 {
    x is greater than 5
} .else if x == 5 {
    x is equal to 5
} .else {
    x is less than 5
}
```

### Loops

The language supports range-based `for` loops. 

Syntax:

```txt
.for variable in start..end {
    // body
}
```

* `start` is inclusive.
* `end` is exclusive.

Example:

```txt
.for i in 1..4 {
    Item ${i}
}
```

Output:

```txt
Item 1
Item 2
Item 3
```

*Note: The language does not support `while` loops or infinite loops to prevent accidental infinite rendering.*

---

## 7. Macros

Macros are reusable template fragments. They are flat (no nested macro definitions) and do not introduce complex lexical scoping.

### Definition

Syntax:

```txt
.macro name(param1, param2) {
    // macro body
}
```

Example:

```txt
.macro greet(name) {
    Hello, ${name}!
}
```

### Invocation

Macros are invoked using the `.` prefix followed by the macro name and arguments in parentheses. Quotes around string arguments are optional.

Syntax:

```txt
.name(arg1, arg2)
```

Example:

```txt
.greet(Alice)    // Outputs: Hello, Alice!
.greet("Bob")    // Outputs: Hello, Bob!
```

---

## 8. Block Macros and Literal Blocks

Macros can accept a "block" parameter, allowing them to act as wrappers or layout generators.

### Block Macro Definition

A block parameter is declared in square brackets `[]` after the standard parameters.

Syntax:

```txt
.macro name(params)[block_param] {
    // body
}
```

Example:

```txt
.macro repeat(n)[content] {
    beginning
    .for i in 1..n {
        ${content}
    }
    ending
}
```

### Literal Blocks

When invoking a block macro, the block argument is passed using a **Literal Block**, delimited by `{"` and `"}`.

Syntax:

```txt
.name(args) {"
    literal text
"}
```

Example:

```txt
.repeat(3) {"
    hi
"}
```

Output:

```txt
beginning
    hi
    hi
    hi
ending
```

### Literal Block Rules

1. **Strict Whitespace:** Everything inside `{"` and `"}` is captured exactly as written, including all indentation and newlines.
2. **No Interpolation:** Literal blocks are raw strings. `${ ... }` inside a literal block is not evaluated; it is treated as raw text.
3. **Strict Terminator:** The sequence `"}` strictly terminates the block. It is consumed by the parser and does not appear in the output.
4. **No Magic Variables:** Because literal blocks are raw strings evaluated at the call site, they cannot access internal loop variables of the macro they are passed into.

---

## 9. Imports

Templates can be composed by importing other template files. Imports are resolved at compile-time.

Syntax:

```txt
.import "path/to/file.tmpl"
```

Example:

```txt
.import "./header.tmpl"
.import "https://example.com/shared/footer.tmpl"
```

* Local paths are resolved relative to the current file or a configured base directory.
* URLs are fetched at compile-time. (Note: Fetching remote files may impact compile times and requires network access).

---

## 10. Built-in Types and Collections

While the language is dynamically typed under the hood, it recognizes the following literal types for inference:

* **Integer:** `10`, `-5`
* **Float:** `3.14`, `0.001`
* **String:** `"hello"`
* **Boolean:** `true`, `false`
* **List/Array:** `[1, 2, 3]`
* **Dictionary/Map:** `{"key": "value"}`

---

## 11. Compilation and Execution Model

### File Extensions

The compiler strips the `.tmpl` extension from the source file to determine the output file name.

* `main.tmpl` $\rightarrow$ `main`
* `index.html.tmpl` $\rightarrow$ `index.html`
* `query.sql.tmpl` $\rightarrow$ `query.sql`

### Execution Phases

1. **Lexing & Parsing:** The compiler reads the source file, separating Raw Text from Directives (`.var`, `.if`, etc.) and Interpolation (`${}`).
2. **Import Resolution:** All `.import` directives are fetched and parsed recursively.
3. **Macro Registration:** All `.macro` definitions are registered in a global, flat scope.
4. **Evaluation:** The compiler traverses the parsed tree. 
   * Raw text is written to the output buffer.
   * Directives are evaluated.
   * Interpolations are evaluated and written to the output buffer.
5. **Output:** The final buffer is written to the target file.

### Error Handling

* **Undefined Variables/Macros:** Results in a compile-time error.
* **Unterminated Blocks:** Missing `}` or `"}` results in a compile-time error.
* **Type Mismatches:** e.g., adding a string to an integer, results in a compile-time error.

---

# End of Specification
