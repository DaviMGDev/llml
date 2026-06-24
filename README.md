# LLML — LLM Language Family

> A family of programming languages designed for, by, and with Large Language Models.

## Overview

**LLML** (LLM Language) is a collection of related language specifications that explore how programming languages can be designed with LLMs as first-class participants — not just as code generators, but as interpreters, runtime components, and even authors.

The family currently includes three languages, each at a different point on the spectrum between deterministic execution and LLM-native interaction:

| Language | File Extension | Spec File | Paradigm |
|----------|---------------|-----------|----------|
| **Lingua** | `.lg` | [`spec.lg.md`](./spec.lg.md) | Fully deterministic, verbose, compile-time metaprogramming |
| **LLML** | `.llml` | [`main.llml`](./main.llml) | Hybrid: deterministic core + LLM-native features |
| **Pseudo** | `.pseudo` | [`main.pseudo`](./main.pseudo) | Prompt-centric, flexible, LLM-interpreted DSL |

---

## Languages

### 🏛️ Lingua (`.lg`)

A deterministic, verbose programming language designed as a **stable base for dialect creation**.

Key features:
- **Verbose syntax** — optimised for parsing, tooling, and readability over typing speed
- **Aliases & macros** — users create custom dialects on top of the stable base
- **Strong type system** — integers, floats, strings, booleans, pointers, generics, unions, enums
- **Memory model** — value types (structs) and reference types (classes with tracing GC)
- **Design by contract** — `require`, `ensure`, `invariant`, `can`
- **Concurrency** — channels (buffered/unbuffered), lightweight tasks (similar to goroutines)
- **Metaprogramming** — compile-time macros with iteration and substitution
- **Reactive state & state machines** — built-in event system and state machine DSL
- **Decorators** — function-transforming decorators

[Read the full Lingua specification →](./spec.lg.md)

### ⚙️ LLML (`.llml`)

A **hybrid language** interpreted by both a deterministic engine and an LLM. Traditional programming constructs coexist with LLM-native features.

Key features:
- **Standard programming** — variables, functions, classes, inheritance, control flow, loops
- **`prompt()` built-in** — calls the LLM at runtime, with access to available tools
- **`tool` keyword** — exposes functions as LLM-visible tools (with documentation)
- **`~=` operator** — semantic approximate equality (optimised to avoid unnecessary LLM calls)
- **`Agent` class** — subagent system for delegating tasks to specialised LLM agents
- **Invariants** — validated rules on variables and types, usable for type coercion from LLM output
- **Type-annotated `prompt()`** — `result: number = prompt(...)` forces the LLM to return a specific type

[Read the LLML reference →](./main.llml)

### 💬 Pseudo (`.pseudo`)

A **prompt-centric DSL** designed to be written and interpreted by LLMs. Code is essentially structured prompts, with lightweight conventions for control flow and data.

Key features:
- **Natural-language syntax** — `variable = value`, `for x in container:`, `if condition:`
- **Embedded formats** — inline JSON, YAML, TOML, Markdown with type annotations
- **Flexible assignment** — `pi is 3.14`, `me as user`, alongside `x = 10`
- **Comments are stripped** — never sent to the LLM
- **Intended for tooling** — formatter, preprocessor to Markdown, syntax highlighting
- **Designed with LLM skills in mind** — skills for writing, reviewing, understanding, and translating to/from natural language

[Read the Pseudo reference →](./main.pseudo)

---

## Philosophy

The LLML family is grounded in a few core ideas:

1. **LLMs are not just code generators** — they can be runtime interpreters, agents, and collaborators.
2. **Deterministic and non-deterministic code can coexist** — statically typed, predictable constructs handle what they're good at; LLM-native features handle semantic understanding, fuzzy matching, and open-ended tasks.
3. **Verbose is a feature** — especially for Lingua, verbosity simplifies parsing, tooling, and provides a stable foundation for custom dialects.
4. **Languages should be designed for their interpreters** — if an LLM is the interpreter, the syntax should play to its strengths (natural-language-adjacent structures, flexible formatting, semantic operators).

---

## Project Structure

```
llml/
├── spec.lg.md       # Lingua (.lg) language specification
├── main.llml        # LLML reference / self-describing spec
├── main.pseudo      # Pseudo language reference
├── README.md        # This file
└── .git/
```

---

## Status

| Language | Status |
|----------|--------|
| Lingua (`.lg`) | Specification draft — compiler/parser TBD |
| LLML (`.llml`) | Specification draft — interpreter TBD |
| Pseudo (`.pseudo`) | Specification draft — formatter/preprocessor TBD |

All three languages are in early design exploration. The specifications evolve as ideas are tested and refined.

---

## Related

- The `~=` (semantic approximate equality) operator and `prompt()` built-in make LLML a potential substrate for **agentic programming** — where the LLM acts as both runtime and decision-maker.
- Pseudo is designed to pair with LLM skills (custom agent capabilities) for writing, reviewing, and converting between pseudo-code and natural language.
- Lingua's macro system and aliases make it a **language-building language** — new DSLs can be created without writing a new parser.

---

## License

MIT — see the LICENSE file for details.
