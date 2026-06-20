# LLML

A pseudocode language with Python-like syntax, designed to be interpreted by AI agents.

## Philosophy

LLML is not a real programming language. There is no compiler, no runtime, no interpreter. It's a **structured way to write prompts** for LLMs that happen to look like code.

The agent reading LLML is smart enough to:
- Infer types, attributes, and methods from context
- Understand natural language mixed with code
- Figure out what to return and what to do based on how you use it

You don't need strict schemas or verbose type definitions. You just need enough structure so the agent knows what you mean.

> **File extension:** LLML programs use the `.llml` extension. Do **not** use `.py` — LLML is not valid Python (`~=`, `is <phrase>`, inferred attributes are not Python syntax) and a `.py` suffix will make editors and linters report false syntax errors.

## Language Reference

LLML uses Python as a starting point. If it looks like Python, it probably works like Python — with the additions below. The reference enumerates everything an agent needs to interpret a `.llml` file consistently.

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

- `~=` is **fuzzy semantic equivalence**. Both operands may be values or natural-language phrases.
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

Rule of thumb: if you'd write it as a fuzzy "is this kind of thing?" question, use `~=`. If you want a direct identity or type check (with an optional phrase predicate), use `is`.

### Built-in functions

| Function | Behavior |
|----------|----------|
| `agent(prompt)` | Treat the string as an LLM prompt. `${...}` interpolation applies. **Returns a value iff its result is bound** (`x = agent(...)`); as a bare statement it is fire-and-forget. The return type is inferred from how the result is used. |
| `print(str)` | Emit the string literally. **No semantic evaluation** — `print` is not a prompt. `${...}` interpolation still applies. |
| `bash(cmd)` | Run a shell command via the host agent's shell tool and return the result. Return type is inferred from usage (a list when iterated, a string when printed, etc.). |

#### `agent()` return contract

- **Bound:** `x = agent("...")` — the agent produces a value and binds it to `x`. The value's type is inferred from how `x` is used afterwards.
- **Statement:** `agent("...")` on its own line — fire-and-forget; no value is captured.
- The agent decides what to return based on the prompt and the surrounding usage. If the prompt asks a question, the answer is the value. If the prompt requests an action with no natural result, the value is `true`/confirmation.

```python
file = agent("which file has more lines?")   # bound: file = the answer
print(file)

agent("write an index.html with a dark theme")  # statement: just do it
```

### String interpolation

`${expr}` inside any string is replaced by the value of `expr`. Applies to both `agent(...)` and `print(...)`.

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

The same applies to methods — if you call `x.read()`, the agent infers a sensible implementation from what `x` is.

## Examples

See [`examples/`](examples/):

- [`example.llml`](examples/example.llml) — full feature tour.
- [`count_ai_files.llml`](examples/count_ai_files.llml) — `for` + `bash()` + `is <phrase>` + counter.
- [`summarize_history.llml`](examples/summarize_history.llml) — inferred attributes + `~=` on file contents.
- [`agent_return_value.llml`](examples/agent_return_value.llml) — the `agent()` return contract.
- [`functions_and_types.llml`](examples/functions_and_types.llml) — `def`, annotations, `~=` on numbers.
- [`compose_agents.llml`](examples/compose_agents.llml) — chaining multiple `agent()` calls.

## Interpreting LLML

LLML is executed by an AI agent, not a runtime. This repository ships an
**interpreter skill** that teaches a host agent how to run a `.llml` file
step-by-step:

- [`skills/interpreter/`](skills/interpreter/) — the interpreter skill.

Load it in an agent harness (e.g. [pi](https://github.com/earendil-works/pi-coding-agent)) and point it at a `.llml` file.

## Out of scope

To keep interpretation consistent across models, the following are **not** part of LLML v1:

- No compiler, parser, or runtime — LLML is always agent-interpreted.
- No real Python `import` or standard library. Do not assume `import os`, `import json`, etc. work. Use `bash()` to reach the shell instead.
- No formal grammar (BNF/EBNF). The Language Reference above is the spec.
- No automated conformance suite (future work).

## Safety

LLML has **no sandbox**. `bash()` runs real shell commands, `${...}` interpolation is unchecked, and the agent interprets the program freely. **Only run `.llml` files you trust.** LLML is not safe for untrusted input.

## Why?

Because sometimes you want to give an agent instructions that are more structured than plain English but less rigid than actual code. LLML is that middle ground — Python enough to be familiar, loose enough to let the agent figure out the rest.

## License

MIT — see [LICENSE](LICENSE).
