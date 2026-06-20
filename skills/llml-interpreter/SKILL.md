---
name: llml-interpreter
description: >
  Interprets and executes .llml (LLML) pseudocode files step-by-step. LLML is a
  Python-like pseudocode language meant to be run by an AI agent. Use when the
  user asks to run, execute, or interpret a .llml file. Self-contained: includes
  the full Language Reference, so it works without any external docs.
---

# LLML Interpreter

This skill teaches the host agent how to execute a `.llml` file. LLML has no
compiler or runtime — the agent *is* the runtime. This skill is
**self-contained**: the Language Reference below is the authoritative spec and
is bundled here so the skill works in any project without external files.

## When to use

- The user asks to "run", "execute", or "interpret" a `.llml` file.
- The user points at a file with the `.llml` extension and asks what it does or
  wants it carried out.

## Prerequisites

- The host agent must have a shell tool (for `bash()`) and the ability to emit
  prompts to itself (for `agent()`).
- Read the **Language Reference** below before executing. It is the spec.

---

## Language Reference

LLML uses Python as a starting point. If it looks like Python, it probably
works like Python — with the additions below. Programs use the `.llml`
extension (not `.py`; LLML is not valid Python).

### Statements

| Statement | Form | Meaning |
|-----------|------|---------|
| Assignment | `name = expr` | Bind `name` to the value of `expr` in working memory. |
| Annotated assignment | `name: type = expr` | Same, with an optional type hint. Types are advisory. |
| Function definition | `def f(a, b) -> t:` ... | Record a callable; body runs on call. |
| `return` | `return expr` | Yield a value from the enclosing `def`. |
| `for` | `for x in iterable:` ... | Iterate; `iterable` is usually `bash(...)` or a list. |
| `if` | `if cond:` ... | Run body if `cond` is true. |
| Expression statement | `expr` | Evaluate for side effects (e.g. `agent(...)`, `print(...)`). |

### Operators

| Operator | Meaning |
|----------|---------|
| `+ - * / %` | Arithmetic, Python semantics. |
| `== != < > <= >=` | Direct comparison (structural/value). |
| `~=` | **Semantic equivalence** — the agent judges whether the left side is semantically equivalent to the right. Fuzzy. Returns `true`/`false`. |
| `is` | **Identity / membership** — direct identity, type identity, or a natural-language predicate (`x is about AI`). Use `is` for direct checks; use `~=` for fuzzy semantic equivalence. |
| `in` | Membership / iteration source. |

#### `is` vs `~=`

- `~=` is **fuzzy semantic equivalence**. Both operands may be values or
  natural-language phrases.
  ```python
  s = "hello"
  s ~= "greeting"            # true — "hello" is semantically a greeting
  file.content ~= "related to history"  # true if the content is about history
  ```
- `is` is **direct/identity**, optionally with a natural-language predicate:
  ```python
  if file is about AI:       # natural-language predicate form of is
      agent("summarize this")
  x is number                # direct type check
  ```

Rule of thumb: if you'd write it as a fuzzy "is this kind of thing?" question,
use `~=`. If you want a direct identity or type check (with an optional phrase
predicate), use `is`.

### Built-in functions

| Function | Behavior |
|----------|----------|
| `agent(prompt)` | Treat the string as an LLM prompt. `${...}` interpolation applies. **Returns a value iff its result is bound** (`x = agent(...)`); as a bare statement it is fire-and-forget. The return type is inferred from how the result is used. |
| `print(str)` | Emit the string literally. **No semantic evaluation** — `print` is not a prompt. `${...}` interpolation still applies. |
| `bash(cmd)` | Run a shell command via the host agent's shell tool and return the result. Return type is inferred from usage (a list when iterated, a string when printed, etc.). |

#### `agent()` return contract

- **Bound:** `x = agent("...")` — the agent produces a value and binds it to
  `x`. The value's type is inferred from how `x` is used afterwards.
- **Statement:** `agent("...")` on its own line — fire-and-forget; no value is
  captured.
- The agent decides what to return based on the prompt and the surrounding
  usage. If the prompt asks a question, the answer is the value. If the prompt
  requests an action with no natural result, the value is `true`/confirmation.

```python
file = agent("which file has more lines?")   # bound: file = the answer
print(file)

agent("write an index.html with a dark theme")  # statement: just do it
```

### String interpolation

`${expr}` inside any string is replaced by the value of `expr`. Applies to
`agent(...)`, `print(...)`, and `bash(...)`.

```python
agent("summarize ${file.path} and save it")
print("the total is ${total}")
```

### Type annotations

Optional. Use them when they help clarity; skip them when context is obvious.

```python
x = 10
s: str = "hi"
y: float = 3.14
n: number = 42        # number == int | float
```

### Attribute & method inference

You don't define schemas. The agent infers attributes and methods from context.

```python
for file in bash("ls"):
    print(file.path)      # inferred: files have paths
    print(file.content)   # inferred: files have content
```

The same applies to methods — if a program calls `x.read()`, infer a sensible
implementation from what `x` is.

### Out of scope (do not assume these work)

- No real Python `import` or standard library (`import os`, `import json`, …).
  Use `bash()` to reach the shell instead.
- No compiler, parser, or runtime — LLML is always agent-interpreted.

---

## Execution model

Walk the file top-to-bottom. Maintain a **working memory** of variable
bindings and defined functions. For each statement, apply the matching rule
from the Language Reference above. Concretely:

### Statement rules

| Statement | Rule |
|-----------|------|
| `name: type = expr` / `name = expr` | Evaluate `expr`, bind to `name`. The annotation is advisory. |
| `def f(params) -> t:` ... | Record `f` as a callable. Do not run the body until called. |
| `return expr` | Evaluate `expr`; yield it from the enclosing `def`. |
| `for x in iterable:` ... | Evaluate `iterable`. If it's `bash(...)`, run the shell command and iterate its results (typically a list of files/lines). Bind `x` to each item and run the body. Infer attributes on `x` from context (e.g. `file.path`, `file.content`). |
| `if cond:` ... | Evaluate `cond`. If true, run the body. |
| Expression statement | Evaluate for side effects (see builtins). |

### Builtins (execution detail)

- **`agent(prompt)`** — interpolate `${...}` in `prompt` using working memory,
  then treat the resulting string as an LLM prompt and dispatch it to yourself.
  - **If bound** (`x = agent(...)`): produce a value. Infer the return type
    from how `x` is used afterward. If the prompt asks a question, the answer
    is the value. If it requests an action with no natural result, bind `true`.
  - **If a bare statement**: perform the action; do not bind anything.
- **`print(str)`** — interpolate `${...}` only. Emit the resulting string
  **literally**. `print` is **not** a prompt and performs **no semantic
  evaluation**. Show the output to the user.
- **`bash(cmd)`** — interpolate `${...}`, then run the command via the host
  shell tool. Return a value inferred from usage: a list when iterated
  (`for x in bash(...)`), a string when printed or otherwise used as a scalar.

### Operators (execution detail)

- Arithmetic and `== != < > <= >=` behave like Python.
- **`~=` (semantic equivalence)** — judge whether the left operand is
  semantically equivalent to the right. Either operand may be a value or a
  natural-language phrase. Yield `true`/`false`. This is a fuzzy, LLM-judged
  check.
- **`is`** — direct identity / type check, optionally with a natural-language
  predicate (`x is about AI`). Use `is` for direct checks, `~=` for fuzzy
  semantic equivalence.
- **`in`** — membership / the source of a `for`.

### String interpolation (execution detail)

`${expr}` inside any string is replaced by the value of `expr` from working
memory. Applies to `agent(...)`, `print(...)`, and `bash(...)`.

### Inference (execution detail)

Infer attributes and methods from context — no schemas are defined. If a
program reads `file.path` and `file.content`, treat each item from
`bash("ls")` as a file object with those attributes. If it calls `x.read()`,
infer a sensible implementation from what `x` is.

## Safety

LLML has **no sandbox**. `bash()` runs real shell commands and `${...}`
interpolation is unchecked. **Only execute `.llml` files you trust.** If a
program looks destructive (`rm -rf`, `sudo`, mass deletion, network
exfiltration), confirm with the user before running `bash()`.

## Worked example

Given this `.llml` file:

```python
count = 0
for file in bash("ls"):
    if file is about AI:
        count++
print(count)
```

Execution:
1. Bind `count = 0`.
2. Run `ls` via the shell tool; iterate the entries as `file`.
3. For each `file`, evaluate `file is about AI` — inspect `file.path` /
   `file.content` and judge whether the file is about AI. If true, increment
   `count`.
4. After the loop, `print(count)` — emit the final count literally.

## Output

Report what you did concisely: each `bash()` command run, each `agent()`
prompt dispatched (and its result if bound), and each `print()` output. If a
value was bound from `agent()`, show it so the user can see what was captured.
