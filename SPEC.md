# LLML Language Specification

> **Version:** 0.1 (Draft)  
> **Status:** Informal Specification  
> **File Extension:** `.llml`

---

## 1. Introduction

LLML (LLM Language) is a **behavioral specification language** for LLM-based agents. It is not a programming language in the traditional sense — there is no compiler, runtime, or interpreter. Instead, an LLM-powered agent reads the `.llml` file and carries out its instructions using real tools (shell commands, file I/O, network requests, etc.).

### Mental Model

- **The agent is the runtime.** Every statement in LLML is interpreted by the agent's judgment, not by a formal execution engine.
- **Commands are executed, not simulated.** A line like `rsync -avz dist/ user@server:/var/www` means the agent should actually run that command.
- **Ambiguity is intentional.** The `~=` operator, natural-language actions, and `.tip()` hints all rely on the agent's semantic understanding to fill in the gaps.

### When to Use LLML

- You want to give an agent structured instructions that are more precise than plain English
- You need conditional logic, loops, and reusable behavior templates
- You want explicit error handling and user-interaction checkpoints
- You want a human-readable spec that also drives actual agent behavior

---

## 2. Syntax Overview

- **Case-sensitive** — `name` and `Name` are different variables
- **Whitespace-sensitive** — indentation indicates block structure (like Python). Standard indent is 4 spaces or 1 tab (consistent within a file)
- **UTF-8 encoding** — the entire file should be valid UTF-8
- **Line endings** — LF (Unix) preferred

---

## 3. Comments

Comments are ignored by the agent. They exist for human readers.

```llml
// Single-line comment

/*
  Multi-line comment
  — also ignored
*/
```

Top-level comments prefixed with `// @rule:` are special — see [Meta-Instructions](#17-meta-instructions-rule).

---

## 4. Variables

Variables are labels for values the agent should remember in its **working memory**. They are scoped to the function or block in which they are declared (lexical scoping, like Python).

### Assignment

```llml
project_root = "/home/user/my-project"
backup_dir = "/tmp/backups"
max_retries = 3
last_commit_hash = ""   // will be filled at runtime
```

### Type Annotations (Advisory)

Type annotations are hints to the agent, never enforced. The agent infers the actual type from context.

```llml
server: remote host = "192.168.1.100"
port: number = 3000
debug_mode: boolean = true
current_branch: git branch = "main"
```

Valid type annotations include: `number`, `string`, `boolean`, `text`, or any natural-language descriptor (`remote host`, `git branch`).

### Variable Interpolation

Variables are interpolated in strings and commands using `$varname` or `${varname}`:

```llml
ls -la $project_root
print("deploying to " + env + "...")
```

The `$` prefix allows the agent to distinguish variables from literal text. Both `$name` and `${name}` forms are valid.

---

## 5. Literals & Data Types

LLML supports the following literal types:

| Type | Examples | Notes |
|---|---|---|
| **String** | `"hello"`, `"deploying to " + env` | Double-quoted. Supports concatenation with `+`. |
| **Number** | `3`, `3000`, `3.14` | Integer and float, Python-like semantics. |
| **Boolean** | `true`, `false` | Lowercase. |
| **Null / Empty** | `""`, empty string | Represents an unset or unknown value. |
| **JSON Object** | `{ "key": "value" }` | Inline JSON — see [JSON Data](#15-json-data-structures). |
| **JSON Array** | `["api", "worker"]` | Inline JSON array. |

There is no explicit `null` or `undefined` keyword — use an empty string `""` to represent a missing value.

### Type Coercion

The agent handles type coercion pragmatically. String concatenation with `+` coerces numbers to strings. Boolean context (e.g., `if` conditions) treats non-empty values as truthy.

---

## 6. Agent Actions

Agent actions are the "executable" part of LLML. They are statements the agent carries out using its available tools.

### Bash Commands

Any line that looks like a shell command is executed via the agent's shell tool:

```llml
ls -la $project_root
git status
npm test
ping -c 3 10.0.0.1
netstat -tlnp | grep 5432
```

### Natural Language Actions

The agent interprets natural language as actionable intent:

```llml
read the README.md in $project_root and summarize its contents
investigate the recent spike in 500 errors
what is the current disk usage on this machine?
find all large files in $project_root that haven't been modified in 6 months
```

The agent decides what "large" means (e.g., >100MB), what commands to run, and what output to produce.

### Mixed Commands

Natural language and commands can be mixed in the same file — the agent distinguishes them by context.

---

## 7. Control Flow

### Conditionals: `if` / `else`

```llml
if file_exists($project_root + "/package.json") {
    npm install
    npm run build
} else {
    print("no package.json found — skipping build")
}
```

`else if` chains are supported:

```llml
if this.name ~= "web server" {
    curl -f http://localhost:80
} else if this.name ~= "database" {
    pg_isready
} else {
    systemctl is-active $this.name
}
```

### Loops: `for`

```llml
for file in ls *.js {
    npx eslint --fix $file
}

for service in config.services {
    curl -f $config.health_endpoints[service]
}
```

The right-hand side of `in` is typically a shell command (like `ls`) or a list variable. The agent iterates over results, binding each item to the loop variable.

### `return`

Returns from a function. The agent stops executing the function body and, if applicable, provides the value to the caller.

```llml
step("test") {
    if $test_results ~= "tests failed" {
        print("tests failed — aborting pipeline")
        return .tip(stop the pipeline here)
    }
}
```

---

## 8. Operators

### Arithmetic

| Operator | Meaning |
|---|---|
| `+` | Addition or string concatenation |
| `-` | Subtraction |
| `*` | Multiplication |
| `/` | Division |
| `%` | Modulo |

Python-like semantics.

### Comparison

| Operator | Meaning |
|---|---|
| `==` | Structural/value equality |
| `!=` | Structural/value inequality |
| `<` `>` `<=` `>=` | Numeric/lexicographic comparison |

### `~=` — Semantic Match (Fuzzy)

**`~=` is the most distinctive operator in LLML.** It is not a type check, not a regex, and not a string comparison. It is a **semantic classifier**: the agent judges whether the left side matches the *concept* described on the right side. Both operands may be values or natural-language phrases.

```llml
error_message = "FATAL: cannot connect to database at 10.0.0.1:5432"

when error_message ~= "connection error" {
    // agent recognizes this as a network/DB connectivity issue
    ping -c 3 10.0.0.1
    netstat -tlnp | grep 5432
}
```

Other examples:

```llml
$raw_data_preview ~= "has header row"       // agent inspects CSV content
$test_results ~= "tests failed"              // agent interprets test output
$smoke_results ~= "all endpoints healthy"    // agent judges health checks
```

**Rule of thumb:** If you'd ask a human "is this kind of thing X?", use `~=`. If you want exact equality, use `==`.

### `~=` vs `==` vs `is`

| Operator | Type | Example | Semantics |
|---|---|---|---|
| `==` | Structural | `env == "production"` | Exact value equality |
| `~=` | Semantic | `error_msg ~= "connection error"` | Fuzzy concept matching |
| `is` | Identity | `file is about AI`, `x is number` | Direct identity, type check, or natural-language predicate |

The `is` operator is used for direct identity/type checks (e.g., `x is number`, `file is about AI`) whereas `~=` is always fuzzy semantic equivalence.

### `in`

Membership test and iteration source:

```llml
for file in ls *.js { ... }
if "api" in config.services { ... }
```

---

## 9. The `when` Keyword — State-Based Branching

`when` is a state-based routing construct. It evaluates an expression against multiple semantic cases, executing the first matching block.

```llml
system_state = ""

when $system_state ~= "healthy" {
    print("system is healthy — running routine checks...")
    df -h
    uptime
} else when $system_state ~= "degraded" {
    print("system degraded — investigation needed")
    investigate()
} else when $system_state ~= "down" {
    print("CRITICAL: system is down")
    alert_oncall("system is down — immediate attention required")
    emergency_recovery()
}
```

`when` is similar to `if`/`else if`/`else` but semantically oriented: it pairs naturally with the `~=` operator to perform **concept-based routing**. A bare `else` block acts as the fallback.

---

## 10. Functions

Functions are reusable agent-behavior templates. Unlike traditional programming, LLML functions describe *actions* the agent should take, not abstract computations.

### Definition

```llml
name(params) {
    // body — agent interprets and executes
}
```

Examples:

```llml
deploy(env) {
    print("deploying to " + env + "...")
    npm run build

    if env == "production" {
        rsync -avz dist/ user@prod-server:/var/www/app
        ssh user@prod-server "systemctl restart app"
    } else {
        rsync -avz dist/ user@staging-server:/var/www/app-staging
    }

    print("deployment to " + env + " complete!")
}

rollback(version) {
    print("rolling back to version " + version)
    ssh user@prod-server "docker pull app:" + version
    ssh user@prod-server "docker-compose up -d"
}

update_system() {
    print("updating system packages...")
    apt update
    apt upgrade -y
    // ... error handling ...
}
```

### Calling

```llml
deploy("staging")
rollback("previous")
update_system()
```

### Semantics

- Functions are **recorded** when defined; their bodies run only when called.
- The agent interprets the body step-by-step each time the function is called.
- There is no explicit return type — the agent infers what a function produces from context and usage.
- Recursion is supported (e.g., `update_system()` calling itself on retry).

---

## 11. The `.tip()` Hint System

`.tip()` provides **extra context** that guides how the agent interprets and executes a statement. Without a tip, the agent relies on default judgment. With a tip, the agent follows the specific guidance.

### Syntax

```llml
action() .tip(instruction)
```

Tips can be attached to:
- Function calls
- Bash commands
- `return` statements
- Any action line

### Examples

```llml
// Precision tip — tells the agent exactly what to do
cleanup_temp_files() .tip(remove all .tmp files older than 7 days in /tmp, use find -mtime)

// Safety tip — warns the agent about destructiveness
migrate_database() .tip(this is a destructive operation — ask the user for confirmation first)

// Complexity tip — guides debugging workflow
analyze_test_failures() .tip(look at the test output and identify which tests failed)

// Tool-selection tip
send_email(...) .tip(use curl or mail command to actually send the email)

// Process tip
npm run lint .tip(fix any auto-fixable issues with --fix)

// Flow-control tip
return .tip(stop the pipeline here)
```

### Purpose

Tips exist because the agent may interpret an action in multiple valid ways. A tip disambiguates without requiring rigid syntax or additional variables.

---

## 12. Classes

Classes define **structured agent behaviors** with state (properties) and methods.

### Definition

```llml
class ServiceManager {
    name: text
    pid: number = -1

    constructor(name) {
        this.name = name
    }

    start() {
        print("starting " + this.name)
        systemctl start $this.name
        this.pid = pgrep -f $this.name
    }

    stop() {
        print("stopping " + this.name)
        systemctl stop $this.name
        this.pid = -1
    }

    restart() {
        this.stop()
        this.start()
    }

    health_check() .tip(run the appropriate health check for this service) {
        if this.name ~= "web server" {
            curl -f http://localhost:80
        } else if this.name ~= "database" {
            pg_isready
        } else {
            systemctl is-active $this.name
        }
    }
}
```

### Instantiation

```llml
api = new ServiceManager("api")
db = new ServiceManager("postgresql")

api.start()
db.start()

api.health_check()
db.health_check()
```

### Rules

- **`constructor(name)`** — Special method called on instantiation. Sets up initial state.
- **`this`** — Refers to the current instance. Used to access properties and methods.
- **Properties** — Declared as `name: type = default`. The type annotation is advisory; the default value is used when no value is provided.
- **Methods** — Can use `.tip()` hints just like functions.
- **Inheritance** — Not part of LLML v0.1. Classes are standalone.

---

## 13. Pipelines

Pipelines provide a structured way to define multi-step workflows.

### Definition

```llml
pipeline: concept = "CI/CD deployment"

step("lint") {
    print("running linter...")
    npm run lint .tip(fix any auto-fixable issues with --fix)
}

step("test") {
    print("running tests...")
    npm run test:coverage

    if $test_results ~= "tests failed" {
        print("tests failed — aborting pipeline")
        analyze_test_failures() .tip(look at the test output and identify which tests failed)
        return .tip(stop the pipeline here)
    }
}

step("build") {
    print("building...")
    npm run build

    if $build_output ~= "build failed" {
        print("build failed — aborting")
        analyze_build_errors()
        return
    }
}

step("deploy") {
    print("deploying to production...")
    deploy("production")
}

step("smoke_test") {
    print("running smoke tests against production...")
    curl -f https://app.example.com/health
    curl -f https://api.example.com/v1/health

    if $smoke_results ~= "all endpoints healthy" {
        print("deployment successful!")
    } else {
        print("smoke tests failed — initiating rollback")
        rollback("previous")
    }
}
```

### Execution

```llml
pipeline.run()
```

The agent executes steps in order. A `return` inside a step halts the pipeline.

The `pipeline: concept = "..."` declaration is optional and serves as a description the agent can reference for context.

---

## 14. User Interaction

LLML provides two built-in mechanisms for involving the user.

### `ask_user(message)`

The agent pauses execution, presents the message to the user, and waits for a response. The user's answer informs subsequent behavior.

```llml
ask_user("package update failed with an unknown error. how should I proceed?")
ask_user("where is the raw data file?")
ask_user("unrecognized data format. how should I parse this?")
```

### `confirm(message) { ... }`

The agent presents a confirmation prompt. The block body executes only if the user confirms.

```llml
confirm("are you sure you want to delete all logs?") {
    rm -rf /var/log/old/*
    print("logs cleared")
}
```

### Natural Language Checkpoints

LLML also supports natural-language instructions to ask the user:

```llml
before proceeding with the database migration, confirm with the user that they have a recent backup
```

The agent recognizes these as implicit interaction points.

---

## 15. JSON Data Structures

LLML supports inline JSON for structured data.

### Definition

```llml
config = {
    "services": ["api", "worker", "scheduler"],
    "health_endpoints": {
        "api": "http://localhost:3000/health",
        "worker": "http://localhost:3001/health"
    },
    "alert_email": "ops@example.com"
}
```

### Access

Properties are accessed with dot notation or bracket notation:

```llml
for service in config.services {
    endpoint = config.health_endpoints[service]
    curl -f -s -o /dev/null $endpoint
    // ...
}
```

The agent treats JSON objects and arrays like familiar data structures, supporting iteration, indexing, and property access.

---

## 16. Error Handling

LLML supports agent-level resilience. Errors are real — the agent should handle them gracefully.

### Checking Exit Codes

```llml
if $last_exit_code != 0 {
    // command failed — investigate
}
```

`$last_exit_code` is a built-in variable the agent tracks, reflecting the exit status of the most recently executed command.

### Semantic Error Classification

Use `when` with `~=` to classify errors semantically:

```llml
apt update
apt upgrade -y

if $last_exit_code != 0 {
    print("package update failed — investigating...")
    cat /var/log/apt/term.log | tail -30

    when $apt_error ~= "held broken packages" {
        apt --fix-broken install
        apt upgrade -y
    } else when $apt_error ~= "network issue" {
        print("network unreachable — will retry in 30 seconds")
        sleep 30
        update_system() .tip(retry the update)
    } else {
        print("unexpected error — notify user")
        ask_user("package update failed with an unknown error. how should I proceed?")
    }
}
```

### Retry Pattern

Functions can call themselves to retry:

```llml
update_system() {
    // ...
    sleep 30
    update_system() .tip(retry the update)
}
```

### Fallback to User

When the agent cannot determine how to proceed, it asks the user:

```llml
ask_user("package update failed with an unknown error. how should I proceed?")
```

---

## 17. Meta-Instructions (`@rule`)

Top-level comments prefixed with `// @rule:` are meta-instructions the agent reads as behavioral rules. They guide the agent's conduct throughout execution.

```llml
// @rule: before modifying any file, check if it exists and show a diff
// @rule: when running destructive commands, ask the user for confirmation
// @rule: if a command fails, always capture stderr and show it to the user
// @rule: prefer explicit paths over relative paths
```

Rules are:
- **Advisory** — the agent should follow them but may override if the situation demands
- **Global** — they apply for the entire execution of the file
- **Agent-interpreted** — the agent reads the natural-language rule and translates it into behavioral constraints

---

## 18. Built-in Functions & Conventions

These functions and conventions appear in LLML programs and are recognized by the agent.

### Built-in Functions

| Function | Behavior |
|---|---|
| `print(message)` | Emit the message to the user. No semantic evaluation — literal output. String interpolation (`$var`) still applies. |
| `file_exists(path)` | Check if a file exists at the given path. Returns `true`/`false`. |
| `ask_user(message)` | Pause and ask the user for input — see [User Interaction](#14-user-interaction). |
| `confirm(message)` `{ ... }` | Ask for user confirmation before executing a block — see [User Interaction](#14-user-interaction). |
| `pipeline.run()` | Execute all defined `step()` blocks in sequence — see [Pipelines](#13-pipelines). |

### Convention Functions (Agent-Interpreted)

These are not built-in but are common conventions the agent understands:

| Convention | Meaning |
|---|---|
| `investigate()` | The agent decides what diagnostic commands to run based on context |
| `alert_oncall(message)` | Notify the on-call team (via email, Slack, etc. — agent decides how) |
| `emergency_recovery()` | Execute emergency recovery procedures (agent decides based on system context) |
| `analyze_test_failures()` | Inspect test output and identify specific failures |
| `analyze_build_errors()` | Inspect build output and identify specific errors |
| `send_email(to, subject, body)` | Send an email. The agent chooses the method (curl, mail command, etc.). |

The agent infers the behavior of these convention functions from their name, context, and any `.tip()` hints attached.

---

## 19. String Interpolation

`$varname` or `${varname}` inside any string is replaced with the variable's value from working memory.

```llml
print("deploying to " + env + "...")
ssh user@prod-server "docker pull app:" + version
ls -la $project_root
```

Interpolation applies in:
- Bash commands: `ls -la $project_root`
- Strings passed to `print()`: `print("found raw data at " + raw_data_path)`
- Strings in function calls: `systemctl start $this.name`
- Any string context

The `+` operator can also concatenate variables with strings: `"deploying to " + env + "..."`.

---

## 20. Natural Language Actions

The agent interprets natural language as actionable intent. These are lines that are not valid bash commands and not valid LLML syntax — the agent fills in the details.

```llml
investigate the recent spike in 500 errors
what is the current disk usage on this machine?
find all large files in $project_root that haven't been modified in 6 months
```

The agent will:
1. Understand the intent from natural language
2. Decide on appropriate commands or actions
3. Execute them
4. Report results

Natural language actions coexist with structured LLML constructs throughout the file.

---

## 21. Agent Variable Reference

The agent maintains certain implicit variables:

| Variable | Description |
|---|---|
| `$last_exit_code` | Exit code of the last executed command (0 = success, non-zero = failure) |
| `$result` | Result of the last expression or command evaluation |
| `$test_results` | Output of the last test run |
| `$build_output` | Output of the last build command |
| `$smoke_results` | Output of the last smoke test run |
| `$apt_error` | Error output of the last apt command |
| `$raw_data_preview` | Preview (first few lines) of a data file |

These are not predefined; they are set by the agent's execution context as the program runs. The `$` prefix helps the agent distinguish them from regular variables.

---

## 22. Informal Grammar

```
program        = { statement | comment | meta_rule }
statement      = assignment | annotated_assignment | agent_action
               | if_stmt | for_stmt | when_stmt | function_def
               | class_def | step_def | pipeline_run
               | return_stmt | confirm_stmt | expression

comment        = "//" text newline
               | "/*" text "*/"

meta_rule      = "//" "@rule:" text newline

assignment     = identifier "=" expression
annotated_assignment = identifier ":" type "=" expression

agent_action   = bash_command | natural_language_text

bash_command   = text   { interpreted as shell command }

if_stmt        = "if" condition block
                 { "else" "if" condition block }
                 [ "else" block ]

for_stmt       = "for" identifier "in" expression block

when_stmt      = "when" condition block
                 { "else" "when" condition block }
                 [ "else" block ]

function_def   = identifier "(" [ params ] ")" block

class_def      = "class" identifier "{" { property | method } "}"
property       = identifier ":" type [ "=" expression ]
method         = identifier "(" [ params ] ")" [ ".tip(" text ")" ] block

step_def       = "step(" string ")" block
pipeline_run   = "pipeline.run()"

return_stmt    = "return" [ expression ] [ ".tip(" text ")" ]
confirm_stmt   = "confirm(" string ")" block

expression     = literal | identifier | member_access
               | call_expression | binary_op | unary_op
               | "(" expression ")" | "new" identifier "(" args ")"

call_expression = identifier "(" [ args ] ")" [ ".tip(" text ")" ]

member_access  = expression "." identifier
               | expression "[" expression "]"

binary_op      = expression operator expression
operator       = "+" | "-" | "*" | "/" | "%"
               | "==" | "!=" | "<" | ">" | "<=" | ">="
               | "~=" | "is" | "in"

block          = "{" newline { statement } "}"

literal        = string | number | boolean | json_object | json_array
```

> **Note:** This grammar is informal and descriptive, not prescriptive. LLML relies on agent interpretation — there is no parser to enforce these rules. The grammar exists to guide human and agent understanding of valid syntax.

---

## Appendix A: Complete Example

See [`example.llml`](./example.llml) in the project root for a 400-line self-contained example that demonstrates every LLML construct in action:

- Comments and variables
- Agent actions (bash and natural language)
- Conditionals and loops
- Functions and the `~=` operator
- `when` state-based branching
- `.tip()` hints
- JSON data structures
- Classes and instantiation
- CI/CD pipeline with steps
- User interaction (`confirm`, `ask_user`)
- Error handling with retry patterns
- `@rule` meta-instructions
- Data pipeline example (CSV → JSON)

---

## Appendix B: Design Principles

1. **The agent is the runtime** — LLML has no formal execution engine. The agent's judgment bridges the gap between spec and execution.
2. **Real-world execution** — Commands in LLML are meant to be actually carried out, not simulated.
3. **Structured flexibility** — LLML provides structure (variables, control flow, functions) without sacrificing the flexibility of natural language.
4. **Fuzzy over exact** — The `~=` operator and natural-language actions embrace ambiguity rather than trying to eliminate it.
5. **Safety through interaction** — `confirm()`, `ask_user()`, and `@rule` annotations provide explicit human-in-the-loop checkpoints.
6. **Progressive disclosure** — Simple files can use only basic features (variables + agent actions); complex files can layer on functions, classes, pipelines, and error handling.
