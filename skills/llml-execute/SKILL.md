---
name: llml-execute
description: >-
  Executes .llml (LLM Language) behavioral specification files. The agent reads
  a .llml file and carries out its instructions using real tools — bash commands,
  file I/O, conditionals, loops, functions, classes, pipelines, semantic matching,
  and human-in-the-loop checkpoints. Use when the user asks to "run", "execute",
  "play", or "process" a .llml file.
license: MIT
metadata:
  author: DaviMGDev
  version: "1.0"
---

# LLML Execute

Executes `.llml` files by interpreting each construct as an instruction for the
agent to carry out using real tools. The agent *is* the runtime — every command
is executed (not simulated), every condition is evaluated semantically, and every
`.tip()` hint guides how the action is performed.

## When to use

- The user says: "run this .llml file", "execute the spec", "play the llml"
- The user provides a `.llml` file path and expects the agent to follow its instructions
- The user says "deploy using the llml", "process data as specified in the llml"
- The user says "carry out the pipeline defined in my .llml file"
- Any request that involves executing a behavioral specification for an agent

## How to use

```markdown
/skill:llml-execute Run the pipeline in deploy.llml
```

Or simply provide a `.llml` file path — the agent will load this skill automatically.

---

## Built-in Reference: LLML Specification

This section is a self-contained reference to the LLML language. The agent should
use this to understand and execute every construct found in a `.llml` file.

### 1. File Format

- **Extension**: `.llml`
- **Case-sensitive** — `name` and `Name` are different variables
- **Whitespace-sensitive** — indentation indicates block structure (like Python). Standard indent is 4 spaces or 1 tab (consistent within a file)
- **UTF-8 encoding**
- **Line endings**: LF (Unix) preferred

### 2. Comments

```
// Single-line comment — agent ignores

/*
  Multi-line comment — also ignored by agent
*/
```

Top-level comments prefixed with `// @rule:` are meta-instructions — see section [Meta-Instructions](#18-meta-instructions-rule).

### 3. Variables & Assignment

Variables are labels for values the agent remembers in working memory.

```
project_root = "/home/user/my-project"
max_retries = 3
```

Type annotations are hints, never enforced:

```
server: remote host = "192.168.1.100"
port: number = 3000
debug_mode: boolean = true
```

Valid type annotations: `number`, `string`, `boolean`, `text`, or any natural-language descriptor.

**Variable interpolation**: Use `$varname` or `${varname}` in strings and commands:

```
ls -la $project_root
print("deploying to " + env + "...")
```

### 4. Literals & Data Types

| Type | Examples | Notes |
|------|----------|-------|
| String | `"hello"`, `"deploying to " + env` | Double-quoted. Supports concatenation with `+`. |
| Number | `3`, `3000`, `3.14` | Integer and float. |
| Boolean | `true`, `false` | Lowercase. |
| Null/Empty | `""` | Represents unset or unknown value. |
| JSON Object | `{ "key": "value" }` | Inline JSON. |
| JSON Array | `["api", "worker"]` | Inline JSON array. |

**Type coercion**: String concatenation with `+` coerces numbers to strings.
Boolean context treats non-empty values as truthy.

### 5. Agent Actions

**Bash commands** — execute via shell tool:

```
ls -la $project_root
git status
npm test
```

**Natural-language actions** — interpret as actionable intent:

```
read the README.md in $project_root and summarize its contents
investigate the recent spike in 500 errors
```

Mix both freely — the agent distinguishes by context.

### 6. Operators

| Operator | Meaning | Example |
|----------|---------|---------|
| `+` | Addition or string concat | `"hello " + name` |
| `-` | Subtraction | `count - 1` |
| `*` | Multiplication | `retries * 2` |
| `/` | Division | `total / count` |
| `%` | Modulo | `value % 2` |
| `==` | Structural equality | `env == "production"` |
| `!=` | Structural inequality | `env != "production"` |
| `<` `>` `<=` `>=` | Numeric/lexicographic comparison | `count > 0` |
| `~=` | **Semantic match (fuzzy)** | `error_msg ~= "connection error"` |
| `is` | Identity/type check | `x is number`, `file is about AI` |
| `in` | Membership / iteration | `"api" in config`, `for x in items` |

**`~=` is the most distinctive operator.** It is NOT a type check, regex, or string comparison. It is a **semantic classifier**: the agent judges whether the left side matches the *concept* described on the right.

```
when error_message ~= "connection error" {
    ping -c 3 10.0.0.1
}
```

The agent inspects the value and uses semantic understanding to classify it.

### 7. Control Flow

**`if` / `else` / `else if`**:

```
if file_exists($project_root + "/package.json") {
    npm install
} else if file_exists($project_root + "/Makefile") {
    make
} else {
    print("no build file found")
}
```

**`for` loops**:

```
for file in ls *.js {
    npx eslint --fix $file
}

for service in config.services {
    curl -f $config.health_endpoints[service]
}
```

The RHS of `in` is typically a command or list variable. The agent iterates, binding each item to the loop variable.

### 8. The `when` Keyword — State-Based Branching

```
when $system_state ~= "healthy" {
    df -h
    uptime
} else when $system_state ~= "degraded" {
    investigate()
} else when $system_state ~= "down" {
    alert_oncall("system is down")
    emergency_recovery()
}
```

`when` is similar to `if`/`else if`/`else` but semantically oriented — pairs naturally with `~=` for concept-based routing. A bare `else` acts as fallback.

### 9. Functions — Reusable Agent Behavior Templates

**Definition**:

```
name(params) {
    // body
}
```

Example:

```
deploy(env) {
    print("deploying to " + env + "...")
    npm run build
    if env == "production" {
        rsync -avz dist/ user@prod-server:/var/www/app
        ssh user@prod-server "systemctl restart app"
    }
}

rollback(version) {
    print("rolling back to " + version)
    ssh user@prod-server "docker pull app:" + version
    ssh user@prod-server "docker-compose up -d"
}
```

**Calling**:

```
deploy("staging")
rollback("previous")
```

**Semantics**:
- Functions are **recorded** when defined; their bodies run only when called
- The agent interprets the body step-by-step each call
- No explicit return type — agent infers from context
- Recursion is supported (e.g., retry calling itself)

### 10. The `.tip()` Hint System

Provides extra context on how to interpret/execute a statement.

```
action() .tip(instruction)
```

Examples:

```
cleanup_temp_files() .tip(remove all .tmp files older than 7 days in /tmp, use find -mtime)
migrate_database() .tip(this is a destructive operation — ask the user for confirmation first)
return .tip(stop the pipeline here)
npm run lint .tip(fix any auto-fixable issues with --fix)
```

Tips can attach to: function calls, bash commands, `return` statements, any action line.

### 11. Classes — Structured Agent Behaviors

```
class ServiceManager {
    name: text
    pid: number = -1

    constructor(name) {
        this.name = name
    }

    start() {
        systemctl start $this.name
        this.pid = pgrep -f $this.name
    }

    stop() {
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

**Instantiation**:

```
api = new ServiceManager("api")
api.start()
api.health_check()
```

**Rules**:
- `constructor(name)` — Special method called on `new`. Sets up state.
- `this` — Refers to current instance.
- Properties — Declared as `name: type = default`.
- Methods — Can use `.tip()` hints.
- Inheritance — Not part of LLML v0.1.

### 12. Pipelines — Multi-Step Workflows

```
pipeline: concept = "CI/CD deployment"

step("lint") {
    npm run lint .tip(fix any auto-fixable issues with --fix)
}

step("test") {
    npm run test:coverage
    if $test_results ~= "tests failed" {
        return .tip(stop the pipeline here)
    }
}

step("build") { npm run build }
step("deploy") { deploy("production") }

pipeline.run()
```

The agent executes `step()` blocks in order. A `return` inside a step halts the pipeline.

### 13. JSON Data Structures

```
config = {
    "services": ["api", "worker"],
    "health_endpoints": {
        "api": "http://localhost:3000/health"
    },
    "alert_email": "ops@example.com"
}
```

Access with dot or bracket notation:

```
for service in config.services {
    endpoint = config.health_endpoints[service]
    curl -f $endpoint
}
```

### 14. User Interaction

**`ask_user(message)`** — Pause, present message, wait for response.

```
ask_user("package update failed. how should I proceed?")
```

**`confirm(message) { ... }`** — Present confirmation. Block executes only if confirmed.

```
confirm("are you sure you want to delete all logs?") {
    rm -rf /var/log/old/*
}
```

**Natural language checkpoints** — also recognized:

```
before proceeding with the database migration, confirm with the user that they have a recent backup
```

### 15. Error Handling

**Checking exit codes**:

```
if $last_exit_code != 0 {
    // command failed — investigate
}
```

`$last_exit_code` is a built-in implicit variable reflecting the last command's exit status.

**Semantic error classification**:

```
if $last_exit_code != 0 {
    when $apt_error ~= "held broken packages" {
        apt --fix-broken install
    } else when $apt_error ~= "network issue" {
        sleep 30
        retry()
    } else {
        ask_user("unexpected error. how to proceed?")
    }
}
```

**Retry pattern** — functions call themselves:

```
update_system() {
    ...
    if $last_exit_code != 0 {
        sleep 30
        update_system() .tip(retry the update)
    }
}
```

**Fallback to user** when the agent cannot determine how to proceed.

### 16. Built-in Functions & Convention Functions

**Built-in**:

| Function | Behavior |
|----------|----------|
| `print(message)` | Emit message to user. Literal output. |
| `file_exists(path)` | Check if file exists. Returns `true`/`false`. |
| `ask_user(message)` | Pause and ask user for input. |
| `confirm(message) { ... }` | Ask for confirmation before block. |
| `pipeline.run()` | Execute all `step()` blocks in order. |

**Convention functions** (agent interprets from name/context):

| Convention | Meaning |
|------------|---------|
| `investigate()` | Run diagnostic commands based on context |
| `alert_oncall(message)` | Notify on-call team (email, Slack, etc.) |
| `emergency_recovery()` | Execute emergency recovery procedures |
| `analyze_test_failures()` | Inspect test output, identify failures |
| `analyze_build_errors()` | Inspect build output, identify errors |
| `send_email(to, subject, body)` | Send email via curl/mail command |

### 17. Implicit Variables (Agent Tracked)

| Variable | Description |
|----------|-------------|
| `$last_exit_code` | Exit code of last executed command (0 = success) |
| `$result` | Result of last expression/command evaluation |
| `$test_results` | Output of last test run |
| `$build_output` | Output of last build command |
| `$smoke_results` | Output of last smoke test |
| `$apt_error` | Error output of last apt command |
| `$raw_data_preview` | Preview of a data file (first few lines) |

These are set by the agent's execution context as the program runs.

### 18. Meta-Instructions (`@rule`)

Top-level comments prefixed with `// @rule:` are meta-instructions the agent reads as behavioral rules:

```
// @rule: before modifying any file, check if it exists and show a diff
// @rule: when running destructive commands, ask the user for confirmation
// @rule: if a command fails, always capture stderr and show it to the user
// @rule: prefer explicit paths over relative paths
```

**Rules are:**
- Advisory — follow but may override if situation demands
- Global — apply for the entire execution
- Agent-interpreted — natural language → behavioral constraints

---

## Execution Instructions

### Phase 1: Load the `.llml` File

1. Read the specified `.llml` file using the `read` tool
2. If no path is given, look for `*.llml` files in the current directory or ask the user
3. Scan for `// @rule:` meta-instructions first — register them as behavioral constraints for this session
4. Begin interpreting the file sequentially from top to bottom

### Phase 2: Execute Each Construct

Process each line/block according to its type:

| Construct | Agent Behavior |
|-----------|---------------|
| **Comment** (`//`, `/* */`) | Skip entirely — they're for human readers |
| **`@rule`** | Register as behavioral constraint for this execution |
| **Variable assignment** (`x = ...`) | Store the value in working memory. Remember the name and value for later interpolation via `$name` |
| **Annotated assignment** (`x: type = ...`) | Same as assignment — type hint is advisory, store the value |
| **Bash command** | Execute via the `bash` tool. Respect `$last_exit_code` after execution. Interpolate any `$varname` references |
| **Natural-language** | Interpret intent and carry out using available tools. Use `.tip()` hints for guidance |
| **`if` condition** | Evaluate the condition. For `==`/`!=` use exact comparison. For `~=` use semantic judgment. For `file_exists()` check the filesystem. Execute the matching block |
| **`for` loop** | Evaluate the RHS of `in` (run command or iterate list). Bind each item to the loop variable. Execute the body for each item |
| **`when` block** | Evaluate the RHS of each `when`/`else when` clause using semantic judgment (`~=`). Execute the first matching block. If none match, execute `else` |
| **Function definition** | Record the function name, parameter names, and body. Do NOT execute the body yet |
| **Function call** | Look up the recorded function. Bind arguments to parameters. Execute the body. Support recursion |
| **Class definition** | Record the class name, properties (with defaults), constructor, and methods |
| **`new Class(args)`** | Create an instance: run the constructor, set up `this` with properties and methods |
| **Method call** (`obj.method()`) | Look up method on the instance. Execute with `this` bound |
| **`.tip()`** on a line | Read the tip text. Use it to modify HOW the attached action is performed. The tip is context for that single action |
| **`pipeline.run()`** | Execute all previously defined `step()` blocks in definition order. A `return` inside a step halts the pipeline |
| **`step("name") { ... }`** | Record the step body (not executed until `pipeline.run()`) |
| **`return`** | Stop executing the current function/step. Optionally provide a value |
| **`confirm(msg) { ... }`** | Use the `ask_user` tool to present the confirmation. Execute the block only if user confirms |
| **`ask_user(msg)`** | Use the `ask_user` tool to present the message. Use the response to inform subsequent behavior |
| **JSON object/array** | Store as structured data in working memory. Support dot and bracket access |
| **Property access** (`obj.prop`, `obj["key"]`) | Resolve using the stored data structure |
| **`+` on strings** | Concatenate strings |
| **`$varname` / `${varname}`** | Replace with the variable's value from working memory |

### Phase 3: Semantic Operations

For **`~=` (semantic match)**:
- Read the left-side value (could be a command output, variable, error message, etc.)
- Read the right-side concept (a natural-language description)
- Use semantic judgment to answer: "Does the left value match the concept on the right?"
- Return `true` if it does, `false` otherwise
- Examples: `"FATAL: cannot connect to DB" ~= "connection error"` → true

For **`is` (identity/type check)**:
- `x is number` — check if x is numeric
- `file is about AI` — check if file content relates to AI
- Natural-language predicate

For **natural-language actions**:
- Understand the intent
- Decide on appropriate commands/tools
- Execute them
- Report results

### Phase 4: Error Handling During Execution

1. After each bash command, check `$last_exit_code`
2. If non-zero, follow any error-handling logic in the `.llml` file
3. If no error-handling is defined, use the `@rule` meta-instructions for guidance
4. If still uncertain, `ask_user` how to proceed
5. Support retry patterns — if a function calls itself, re-execute the body

### Phase 5: Reporting

After execution completes (or is halted):
- Summarize what was done
- Report any errors or failures
- If a pipeline was run, report each step's outcome
- If the user requested output (via `print` or action results), present it clearly

---

## Examples

### Example 1: Simple Deployment Script

**Input file** (`deploy.llml`):
```llml
env = "staging"
print("deploying to " + env)
npm run build
rsync -avz dist/ user@staging-server:/var/www/app-staging
print("done!")
```

**Agent behavior**: Read the file, run `npm run build`, run `rsync`, report done.

### Example 2: Conditional with Error Handling

**Input file** (`update.llml`):
```llml
update_system() {
    apt update
    apt upgrade -y
    if $last_exit_code != 0 {
        when $apt_error ~= "network issue" {
            print("network issue — retrying in 30s")
            sleep 30
            update_system()
        } else {
            ask_user("update failed. how to proceed?")
        }
    }
}
update_system()
```

**Agent behavior**: Run apt, check exit code, classify error semantically, retry or ask user.

### Example 3: Class-Based Service Manager

**Input file** (`services.llml`):
```llml
class ServiceManager {
    name: text
    constructor(name) { this.name = name }
    start() { systemctl start $this.name }
    stop() { systemctl stop $this.name }
    status() { systemctl status $this.name }
}

api = new ServiceManager("nginx")
api.start()
api.status()
```

**Agent behavior**: Define the class, instantiate, run systemctl commands.

### Example 4: Pipeline with Steps

**Input file** (`pipeline.llml`):
```llml
pipeline: concept = "build and test"

step("install") { npm install }
step("lint") { npm run lint .tip(fix with --fix) }
step("test") {
    npm test
    if $test_results ~= "tests failed" {
        return .tip(stop here)
    }
}
step("build") { npm run build }

pipeline.run()
```

**Agent behavior**: Execute steps in order with semantic condition checking and early exit.

---

## Edge Cases & Gotchas

| Situation | Handling |
|-----------|----------|
| **File doesn't exist** | Ask the user for the correct path. Look for `*.llml` in the current directory |
| **Empty `.llml` file** | Report that the file has no instructions |
| **Unknown syntax** | Use judgment to infer intent; warn the user if ambiguous |
| **`~=` with ambiguous input** | Ask the user if unsure; prefer safe classification |
| **Tip conflicts with safe behavior** | Safety (user confirmation) overrides `.tip()` |
| **Recursive function (infinite loop)** | After 3 retries or 10+ recursive calls, pause and ask user |
| **Bash command not found** | Report the missing command, suggest alternatives |
| **Interpolation of undefined variable** | Warn the user, treat as empty string, proceed |
| **JSON access on non-existent key** | Return empty string, warn the user |
| **Class method called before constructor** | Warn, treat as no-op |
| **`pipeline.run()` with no `step()` definitions** | Warn that pipeline is empty |
| **`confirm()` inside automated/non-interactive context** | Treat `confirm()` as always-approved, warn the user |
| **Cross-platform commands** | Prefer portable commands (`df -h`, `curl`). Note platform assumptions |
| **Very large `.llml` files (>500 lines)** | Process in logical sections. Respect context limits |
