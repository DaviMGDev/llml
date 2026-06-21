---
name: llml-lint
description: >-
  Lints .llml (LLM Language) behavioral specification files — validates syntax,
  structure, and best-practice compliance against the LLML specification.
  Reports issues with severity levels (error, warning, info) and line numbers.
  Use when the user asks to "lint", "validate", "check", or "audit" a .llml file.
license: MIT
metadata:
  author: DaviMGDev
  version: "1.0"
---

# LLML Lint

Validates `.llml` files for syntactic correctness, structural consistency, and
adherence to the LLML specification. Since LLML has no formal runtime, the agent
uses pattern-based validation and semantic judgment to detect issues before
execution.

## When to use

- The user says: "lint this .llml", "validate my .llml file", "check this spec"
- The user says: "is my .llml file correct?", "find issues in this .llml"
- The user says: "audit this behavioral spec", "review my .llml for problems"
- Before executing an untrusted `.llml` file (safety pre-check)
- After writing a `.llml` file to verify correctness

## How to use

```markdown
/skill:llml-lint Check deploy.llml for issues
```

---

## Built-in Reference: LLML Syntax & Structure

This section is a self-contained reference for validating LLML syntax. It focuses
on the structural and syntactic rules the linter checks.

### 1. File Conventions

| Rule | Correct | Incorrect |
|------|---------|-----------|
| Extension | `.llml` | `.py`, `.txt`, `.md` |
| Encoding | UTF-8 | Non-UTF-8 (latin-1, etc.) |
| Line endings | LF (Unix) | CRLF may cause issues |
| Indentation | 4 spaces or 1 tab (consistent) | Mixed spaces/tabs |
| Case sensitivity | `name` ≠ `Name` | Inconsistent casing |

### 2. Comments

```
// Single-line            ✓ Valid
/* Multi-line */          ✓ Valid
// @rule: some rule       ✓ Valid (meta-instruction)
```

Rules:
- `//` must be at the start of the line (may have leading whitespace for indented blocks)
- `/* */` must be properly closed — unclosed multi-line comments are errors
- `// @rule:` only valid at top level (not inside function/class/if blocks)

### 3. Variable Assignments

```
name = "value"                        ✓ Valid
name: type = "value"                  ✓ Valid
name =                               ✗ Missing value
name: = "value"                       ✗ Missing type after colon
name = { missing: brace               ✗ Unclosed JSON
name = "unclosed string               ✗ Unclosed string
123name = "value"                     ✗ Invalid variable name (starts with digit)
```

Rules:
- Variable names: letters, digits, underscores. Must start with a letter or underscore
- Type annotations: colon followed by a type descriptor (natural language OK)
- Value must be present after `=`
- Strings must be double-quoted and properly closed
- JSON objects/arrays must be properly formed

### 4. String & JSON Literals

```
"hello world"               ✓ Valid
"hello " + name             ✓ Valid (concatenation)
"hello world                ✗ Missing closing quote
{ "key": "value" }          ✓ Valid JSON
{ key: "value" }            ✗ JSON keys must be quoted
{ "key": "value",  }        ✗ Trailing comma in JSON
["a", "b"]                  ✓ Valid array
["a", "b",]                 ✗ Trailing comma in array
```

### 5. Block Structure (Braces)

LLML uses `{ }` for blocks (if, for, when, functions, classes, pipelines, confirm).

```
if condition {               ✓ Valid
    command
}
```

Common issues:
- Missing opening brace: `if condition command` ✗
- Missing closing brace → unclosed block error
- Extra closing brace → unexpected `}` error
- Mismatched indentation inside block

### 6. Control Flow

**`if` / `else if` / `else`**:
```
if condition { ... }                  ✓
if condition { ... } else { ... }     ✓
if condition { ... } else if cond { ... } else { ... }  ✓
if condition ...                      ✗ Missing braces
```

**`for` loops**:
```
for var in expression { ... }         ✓
for var in { ... }                    ✗ Missing `in` expression
for var in expr                      ✗ Missing braces
```

**`when` blocks**:
```
when condition { ... } else when cond { ... } else { ... }  ✓
when condition { ... }               ✓
when { ... }                         ✗ Missing condition
```

### 7. Operators

| Operator | Valid Usage | Invalid Usage |
|----------|-------------|---------------|
| `==` | `x == "value"` | `x == ` (missing operand) |
| `!=` | `x != "value"` | `!= y` (missing left operand) |
| `~=` | `err ~= "connection issue"` | `~= "thing"` (missing left operand) |
| `is` | `x is number` | `x is` (missing right operand) |
| `in` | `for x in items`, `"api" in services` | `x in` (missing right operand) |
| `+` | `"a" + "b"`, `1 + 2` | `+ x` (missing left operand) |
| `<` `>` `<=` `>=` | `count > 0` | `> 0` (missing left operand) |

### 8. Functions

```
deploy(env) {                        ✓ Valid
    print("deploying " + env)
}

deploy env) {                        ✗ Missing opening paren
deploy(env {                         ✗ Missing closing paren
deploy(env, name) {                  ✓ Valid (multiple params)
deploy() {                           ✓ Valid (no params)
deploy(env)                          ✗ Missing body braces
```

Rules:
- Function name: same rules as variable names
- Parameters: comma-separated, enclosed in `()`
- Body: enclosed in `{}`
- Recursive calls are valid

### 9. Classes

```
class Name {                         ✓ Valid
    prop: type = default             ✓ Valid
    constructor(params) { ... }      ✓ Valid
    method(params) { ... }           ✓ Valid
}

class { ... }                        ✗ Missing class name
class Name                           ✗ Missing body braces
class Name { prop }                  ✗ Missing type annotation on property
```

Rules:
- Class name: Capitalized by convention, same naming rules as variables
- Properties: must have type annotation (`name: type [= default]`)
- Constructor: special method named `constructor`
- Methods: same syntax as functions
- `this.` prefix for instance members inside methods

### 10. Pipelines

```
pipeline: concept = "description"    ✓ Valid (optional header)
step("name") { ... }                 ✓ Valid
pipeline.run()                       ✓ Valid
step(name) { ... }                   ✗ Step name must be a string literal
step("name") {                       ✗ Unclosed step body
pipeline.run                         ✗ Missing parentheses
```

Rules:
- `pipeline:` declaration is optional
- `step()` name must be a string literal
- Steps are defined before `pipeline.run()`
- Each step must have a body block `{}`

### 11. `.tip()` Attachments

```
action() .tip(text)                  ✓ Valid
command .tip(text)                   ✓ Valid
return .tip(text)                    ✓ Valid

action() .tip                        ✗ Missing parentheses around tip text
action() tip(text)                   ✗ Missing dot before `tip`
.tip(text)                           ✗ Tip without an action to attach to
```

Rules:
- `.tip()` must follow an action, command, or `return` statement
- The tip text must be enclosed in `()`
- Only one `.tip()` per statement

### 12. `@rule` Meta-Instructions

```
// @rule: text                       ✓ Valid (top-level only)
    // @rule: text                   ✓ Valid (leading whitespace OK at top level)

// @rule                            ✗ Missing colon after @rule
```

Rules:
- Must start with `// @rule:` (note the colon)
- Only valid at top level (not inside functions, classes, if blocks, etc.)
- The text after `@rule:` is free-form natural language

### 13. User Interaction

```
confirm("message") { ... }           ✓ Valid
ask_user("message")                  ✓ Valid
confirm("message")                   ✗ Missing block body
ask_user                             ✗ Missing parentheses and arguments
```

### 14. `return` Statement

```
return                               ✓ Valid
return value                         ✓ Valid
return .tip(text)                    ✓ Valid
```

Rules:
- `return` only valid inside functions, methods, or `step()` blocks
- Optional return value after `return`
- Optional `.tip()` attachment

### 15. Variable Interpolation

```
$name                                ✓ Valid
${name}                              ✓ Valid
$123                                 ✗ Undefined variable-like token
$                                    ✗ Dangling dollar sign
```

---

## Validation Instructions

### Phase 1: Load the File

1. Read the specified `.llml` file
2. If no path is given, look for `*.llml` files in the current directory or ask the user
3. Check for basic file-level issues first (encoding, extension, line endings)

### Phase 2: Check File-Level Rules

| Check | Issue | Severity |
|-------|-------|----------|
| File has `.llml` extension | Wrong extension | ❌ Error |
| File is not empty | Empty file | ⚠️ Warning |
| Line endings are LF | CRLF detected | ⚠️ Warning |
| Indentation is consistent | Mixed tabs/spaces | ❌ Error |
| No BOM marker at start | BOM marker present | ⚠️ Warning |
| Valid UTF-8 encoding | Encoding issues | ❌ Error |

### Phase 3: Scan for Structural Issues

Process the file line by line, checking for:

1. **Unclosed strings**: A `"` that starts a string but never closes
2. **Unclosed blocks**: `{` without matching `}` (track brace depth)
3. **Extra closing braces**: `}` with no matching `{`
4. **Unclosed comments**: `/*` without matching `*/`
5. **Orphaned operators**: Operators (`==`, `~=`, `=`, `+`, etc.) missing one or both operands
6. **Malformed variable assignments**: Missing `=`, missing value, invalid name
7. **Invalid JSON**: Unquoted keys, trailing commas, unclosed brackets
8. **Function/class without body**: Missing `{`
9. **`.tip()` without attachment**: `.tip()` on its own line without preceding action
10. **`@rule` inside block**: Meta-instruction not at top level

### Phase 4: Semantic Validation (Agent Judgment)

For issues that require understanding, not just pattern matching:

| Check | How to Judge | Severity |
|-------|-------------|----------|
| Undefined variable reference | Does `$varname` refer to a previously assigned variable? | ⚠️ Warning |
| Unused variable | Variable assigned but never referenced | ⚠️ Info |
| Dead code after `return` | Statements after `return` in same block | ⚠️ Warning |
| `~=` used where `==` would suffice | Is the RHS a concrete value, not a concept? | ℹ️ Info |
| Suspicious `~=` usage | Is the concept too vague to be useful? | ℹ️ Info |
| Deeply nested blocks | Nesting depth > 4 levels | ⚠️ Warning |
| Overly long lines | Lines > 120 characters | ℹ️ Info |
| Missing `pipeline.run()` | Steps defined but never triggered | ⚠️ Info |
| Recursion without exit condition | Function calls itself with no `if` guard | ⚠️ Warning |
| Unused function/class/method | Defined but never called | ℹ️ Info |
| Convention function misspelling | `alert_oncall` vs `alert_on_call` | ℹ️ Info |
| Potential infinite loop | `for` on a command that may never terminate | ⚠️ Info |

### Phase 5: Best Practice Checks

| Check | Guidance | Severity |
|-------|----------|----------|
| `@rule` safety rules present | Missing safety guardrails | ℹ️ Info |
| `confirm()` before destructive ops | Destructive command without confirmation | ⚠️ Warning |
| Error handling after risky commands | No `$last_exit_code` check after risky cmd | ⚠️ Info |
| Meaningful `.tip()` text | `.tip()` with placeholder or empty text | ℹ️ Info |
| Consistent naming convention | `snake_case` vs `camelCase` mixing | ℹ️ Info |
| Variables documented with types | Missing type annotations on variables | ℹ️ Info |

### Phase 6: Report Results

Always present findings in a structured format:

```markdown
## Lint Results: `<filename>`

### ❌ Errors (must fix)
| Line | Issue | Suggestion |
|------|-------|------------|
| 12 | Unclosed string literal | Add closing `"` at end of line |

### ⚠️ Warnings (should fix)
| Line | Issue | Suggestion |
|------|-------|------------|
| 34 | Deep nesting (6 levels) | Consider extracting inner logic into a function |

### ℹ️ Info (consider)
| Line | Issue | Suggestion |
|------|-------|------------|
| 1 | No `@rule` safety meta-instructions | Add `// @rule: before destructive commands, confirm with user` |

### Summary
- **Errors**: 1
- **Warnings**: 3
- **Info**: 5
- **Score**: ⚠️ Needs attention (fix errors and warnings before executing)
```

**Severity definitions**:
- **❌ Error** — Will cause incorrect behavior or failure during execution
- **⚠️ Warning** — May cause issues or indicates poor practice
- **ℹ️ Info** — Style suggestion or optional improvement

**Score levels**:
- ✅ **Clean** — No errors or warnings (info items only)
- ⚠️ **Needs attention** — Has warnings but no errors
- 🚫 **Failing** — Has errors that must be fixed

---

## Examples

### Example 1: Simple Lint

**Input** (`broken.llml`):
```llml
name = "hello"
if name == "hello" {
    print("hi")
```

**Lint output**:
```
## Results: broken.llml

### ❌ Errors
| Line | Issue | Suggestion |
|------|-------|------------|
| 4 | Unclosed block: `{` opened at line 2 has no matching `}` | Add `}` after the `print` line |

### Summary
- Errors: 1 | Warnings: 0 | Info: 0
- Score: 🚫 Failing
```

### Example 2: Multiple Issues

**Input** (`messy.llml`):
```llml
// @rule: be safe
deploy() {
    npm run build
    rsync -avz dist/ server:/var/www
}
```

**Lint output**:
```
## Results: messy.llml

### ⚠️ Warnings
| Line | Issue | Suggestion |
|------|-------|------------|
| 4 | Missing `confirm()` before destructive `rsync` | Wrap in `confirm("deploy to production?")` |

### ℹ️ Info
| Line | Issue | Suggestion |
|------|-------|------------|
| 1 | `@rule` is vague ("be safe") | Be more specific: `// @rule: before modifying files, show a diff` |
| 4 | No error handling after `npm run build` | Add `if $last_exit_code != 0 { ... }` |

### Summary
- Errors: 0 | Warnings: 1 | Info: 2
- Score: ⚠️ Needs attention
```

### Example 3: Clean File

**Input** (`clean.llml`):
```llml
// @rule: before any destructive command, confirm with the user
// @rule: if a command fails, show stderr and ask user how to proceed

env = "staging"

deploy(env) {
    print("deploying to " + env)
    if env == "production" {
        confirm("deploy to production?") {
            npm run build
            rsync -avz dist/ prod-server:/var/www
        }
    } else {
        npm run build
        rsync -avz dist/ staging-server:/var/www
    }
}

deploy(env)
```

**Lint output**:
```
## Results: clean.llml

### Summary
- Errors: 0 | Warnings: 0 | Info: 0
- Score: ✅ Clean — no issues found
```

---

## Edge Cases & Gotchas

| Situation | Handling |
|-----------|----------|
| **Very long files (>1000 lines)** | Process in chunks; report line numbers for first 50 issues then summarize |
| **Generated `.llml` files** | May have consistent formatting issues (trailing commas, etc.) — note this in report |
| **JSON embedded in LLML** | Validate JSON separately — use `python3 -c "import json; json.loads(...)"` if needed |
| **`~=` RHS is a variable** | Check the variable's value is a concept string, not a command |
| **Nested string quotes** | `"he said \"hello\""` — escaped quotes inside strings are valid |
| **Comments inside blocks** | Valid — just skip them during validation |
| **Empty blocks `{}`** | Valid but warn as info |
| **Function with same name as built-in** | E.g., a function named `print` — warn about shadowing |
| **`pipeline.run()` before all steps defined** | Check that all `step()` definitions precede `pipeline.run()` |
| **Class inheritance-like patterns** | Warn that LLML v0.1 doesn't support inheritance |
| **Inconsistent indentation inside blocks** | If indent level changes within a block, flag as error |
| **Variable assigned in one branch only** | Warn that variable may be undefined in other branch |
