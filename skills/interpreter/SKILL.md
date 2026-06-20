---
name: llml-interpreter
description: >
  Interprets and executes .llml (LLML) pseudocode files step-by-step. LLML is a
  Python-like pseudocode language meant to be run by an AI agent. Use when the
  user asks to run, execute, or interpret a .llml file.
---

# LLML Interpreter

This skill teaches the host agent how to execute a `.llml` file. LLML has no
compiler or runtime — the agent *is* the runtime.

## When to use

- The user asks to "run", "execute", or "interpret" a `.llml` file.
- The user points at a file with the `.llml` extension and asks what it does or
  wants it carried out.

## Prerequisites

- Read the LLML Language Reference first. The canonical spec is the project's
  `README.md` (see the **Language Reference** section). If the project has no
  README, the rules below are a self-contained summary.
- The host agent must have a shell tool (for `bash()`) and the ability to emit
  prompts to itself (for `agent()`).

## Execution model

Walk the file top-to-bottom. Maintain a **working memory** of variable bindings
and defined functions. For each statement, apply the matching rule below.

### Statement rules

| Statement | Rule |
|-----------|------|
| `name: type = expr` / `name = expr` | Evaluate `expr`, bind to `name`. The annotation is advisory. |
| `def f(params) -> t:` ... | Record `f` as a callable. Do not run the body until called. |
| `return expr` | Evaluate `expr`; yield it from the enclosing `def`. |
| `for x in iterable:` ... | Evaluate `iterable`. If it's `bash(...)`, run the shell command and iterate its results (typically a list of files/lines). Bind `x` to each item and run the body. Infer attributes on `x` from context (e.g. `file.path`, `file.content`). |
| `if cond:` ... | Evaluate `cond`. If true, run the body. |
| Expression statement | Evaluate for side effects (see builtins). |

### Builtins

- **`agent(prompt)`** — interpolate `${...}` in `prompt` using working memory,
  then treat the resulting string as an LLM prompt and dispatch it to yourself.
  - **If bound** (`x = agent(...)`): produce a value. Infer the return type from
    how `x` is used afterward. If the prompt asks a question, the answer is the
    value. If it requests an action with no natural result, bind `true`.
  - **If a bare statement**: perform the action; do not bind anything.
- **`print(str)`** — interpolate `${...}` only. Emit the resulting string
  **literally**. `print` is **not** a prompt and performs **no semantic
  evaluation**. Show the output to the user.
- **`bash(cmd)`** — interpolate `${...}`, then run the command via the host
  shell tool. Return a value inferred from usage: a list when iterated
  (`for x in bash(...)`), a string when printed or otherwise used as a scalar.

### Operators

- Arithmetic and `== != < > <= >=` behave like Python.
- **`~=` (semantic equivalence)** — judge whether the left operand is
  semantically equivalent to the right. Either operand may be a value or a
  natural-language phrase. Yield `true`/`false`. This is a fuzzy, LLM-judged
  check.
- **`is`** — direct identity / type check, optionally with a natural-language
  predicate (`x is about AI`). Use `is` for direct checks, `~=` for fuzzy
  semantic equivalence.
- **`in`** — membership / the source of a `for`.

### String interpolation

`${expr}` inside any string is replaced by the value of `expr` from working
memory. Applies to `agent(...)`, `print(...)`, and `bash(...)`.

### Inference

You infer attributes and methods from context — no schemas are defined. If a
program reads `file.path` and `file.content`, treat each item from `bash("ls")`
as a file object with those attributes. If it calls `x.read()`, infer a
sensible implementation from what `x` is.

## Safety

LLML has **no sandbox**. `bash()` runs real shell commands and `${...}`
interpolation is unchecked. **Only execute `.llml` files you trust.** If a
program looks destructive (`rm -rf`, `sudo`, mass deletion, network exfiltration),
confirm with the user before running `bash()`.

## Worked example

Given `examples/count_ai_files.llml`:

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

Report what you did concisely: each `bash()` command run, each `agent()` prompt
dispatched (and its result if bound), and each `print()` output. If a value was
bound from `agent()`, show it so the user can see what was captured.
