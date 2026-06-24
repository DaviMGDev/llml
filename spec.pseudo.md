# Language Specification (Draft)

## 1. Philosophy

Pseudo is a prompt-centric DSL designed to be interpreted — and even written — by LLMs.

The language is intentionally loose. It is not a strict language, just a set of conventions that define better agent behaviour.

Pseudo is not intended for compilers, static analysis, or formal type checking. There is no LSP, no linter, and no type checker. The language exists to provide just enough structure for dynamic, LLM-driven workflows while staying flexible enough that an LLM can produce valid code without friction.

The conventions exist to:

* provide predictable structure for LLM interpretation
* keep prompts dynamic through variables and control flow
* make the language easy to write, both by humans and LLMs
* support embedded formats (JSON, YAML, TOML, Markdown) natively

A formatter and a preprocessor (comments → stripped, output → Markdown) are planned. A full toolchain is not.

---

## 2. Comments

Comments exist for human readers. They are **never** seen by the LLM — the preprocessor strips them before the prompt reaches the model.

### Single-line comments

```txt
// this is a comment
```

### Multi-line comments

```txt
/*
this is a comment that
spans multiple lines
*/
```

Comments may appear anywhere in a file. They are removed during preprocessing, before the remaining content is sent to the LLM.

---

## 3. Prompts

Any text that does not match a language construct (comment, declaration, control flow, loop, function) is interpreted as a **prompt** — natural language sent directly to the LLM.
obs: ANY TEXT that is not a comment, **IS** a prompt, there are no distinction between pseudocode and natural language. none. zero. the usage of constructs are just convetional, not enforced 

This is the core idea of Pseudo: code is structured prompts.

```txt
hi, give me a poem
```

```txt
how much is x?
```

```txt
and how much is x + 5?
```

```txt
I'm an adult?
```

Prompts can reference variables declared earlier in the file. The LLM resolves them in context.

Prompts are not quoted — they are bare natural language. A prompt ends at a line boundary, unless it is part of an indented block (see Control Flow / Loops).

---

## 4. Declarations

Variables may be declared in three equivalent styles.

### Assignment style

```txt
x = 10
```

### `is` style

```txt
pi is 3.14
```

### `as` style

```txt
me as user
```

All three styles declare a variable in the current scope. The choice is stylistic. The `is` and `as` styles exist to make declarations read like natural language.

Reassignment uses the same syntax:

```txt
x = 20
```

There are no explicit constants — all variables may be reassigned.

---

## 5. Types

Types are **informal annotations**. They are not enforced at runtime. They serve as hints to the LLM about the expected shape or nature of a value.

### Annotation syntax

```txt
person: adult = {
    name: John
}
```

```txt
person: engineer = {
    name: john
}
```

```txt
answer: correct = some value to a question
```

The type (`adult`, `engineer`, `correct`) is a semantic label. It has no formal definition — it is context the LLM uses during interpretation.

Types may also annotate embedded formats:

```txt
data: yaml =
    name: John
    age: 30
```

---

## 6. Embedded Formats

Pseudo accepts inline data in common formats. The format is specified via a type annotation.

### YAML

```txt
data: yaml =
    name: John
    age: 30
    city: New York
```

### TOML

```txt
another data: toml =
    name = "John"
    age = 30
    city = "New York"
```

### JSON

```txt
other data: json =
    {
        "name": "John",
        "age": 30,
        "city": "New York"
    }
```

### XML

```txt
config: xml =
    <config>
        <name>John</name>
        <age>30</age>
    </config>
```

### Markdown

```txt
description: md =
    # Hello

    This is **Markdown** content.
```

Embedded formats are not parsed by the language. They are passed as-is to the LLM, which interprets them according to their annotated format.

---

## 7. Control Flow

### Block style

Control flow uses a colon and indentation, similar to Python or YAML.

```txt
if condition:
    do something
else if another condition:
    do something else
else:
    do something else
```

The condition is natural language. The body is indented.

### Inline style

A more concise form uses `?` and `;` as delimiters.

```txt
condition? do something ; not condition? do something else;
```

Chained conditions:

```txt
condition?
    do something
not condition?
    another condition?
        do something else
```

Both styles are equivalent. The inline style reads more like natural language; the block style is better for structured branching.

---

## 8. Loops

### For-in

```txt
for item in iterator/range/container:
    do something with item
```

The iterator may be a range expression, a container variable, or a natural-language description.

```txt
for file in ls -lahS:
    move file to <category>/
    example: mv file.jpg Pictures/
```

---

## 9. Lists

Lists use bracket syntax:

```txt
[1, 2, 3, 4]
```

There are no typed arrays or tuples — lists are homogeneous by convention, not by rule.

---

## 10. Functions


### Declaration

```txt
fn name(args: type): type {
    do something
}
```

python like is also accepted

```
def name(args: type) -> type: 
    do something 
```

actually, you can use any function definition syntax, just make sure that is well know enough to the LLM understand 

The body is a natural-language description of what the function does.

```txt
fn somebehaviour(parameters: text) {
    based on parameters, I want you to
    do something.
}
```

Functions are not compiled or type-checked. They serve as reusable prompt templates with parameters.

---

## 11. Tooling

The following tools are planned for the Pseudo language.

### Preprocessor

Strips comments producing a clean Markdown file ready for LLM consumption.

```
pseudo preprocess main.pseudo > output.md
```

### Formatter

Normalises indentation, declaration style, and inline vs block control flow according to a configurable style guide.

### Syntax highlighting

A TextMate grammar or Tree-sitter parser for editor integration (VS Code, Neovim, Helix).

### LLM skills

Skills designed to help LLMs interact with the Pseudo language:

* **Write** — convert natural-language task descriptions into Pseudo code
* **Review** — check Pseudo code for clarity, correctness, and completeness
* **Understand** — explain what a given Pseudo file instructs
* **Convert** — translate between Pseudo and natural language in either direction

---

## 12. Object notation

"Objects" and "classes" in Pseudo are simply JSON notation.

```txt
me = {
    name: Davi,
    age: 21,
    job: Student
}
```

The curly-brace block is treated as a structured value. It uses JSON-like syntax but accepts unquoted keys and values, leaving interpretation to the LLM.

---

# End of Specification
