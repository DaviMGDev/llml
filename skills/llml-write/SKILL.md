---
name: llml-write
description: >-
  Writes .llml (LLM Language) behavioral specification files. Guides the agent
  in composing correct, idiomatic LLML from user requirements — covering
  syntax, structure, patterns, best practices, and anti-patterns. The skill
  embeds the complete LLML specification as a built-in reference.
  Use when the user asks to "write", "create", "generate", "scaffold", or
  "compose" a .llml file.
license: MIT
metadata:
  author: DaviMGDev
  version: "1.0"
---

# LLML Write

Guides the composition of well-structured, spec-compliant `.llml` files. Given
a user's requirements, this skill helps the agent design the right LLML
constructs, follow best practices, and produce clean, idiomatic behavioral
specifications.

## When to use

- The user says: "write an .llml file for...", "create a deploy spec"
- The user says: "generate an llml that does X", "help me write an .llml"
- The user says: "convert this workflow to LLML", "llml-ize this process"
- The user describes a procedure and expects an LLML representation
- The user asks for a template, pattern, or boilerplate in LLML

## How to use

```markdown
/skill:llml-write Create an .llml file that deploys a Node.js app to Kubernetes
```

---

## Built-in Reference: Complete LLML Specification

This section is a self-contained, complete reference to the LLML language.
The agent should use this to compose any `.llml` file correctly.

### 1. File Conventions

- **Extension**: Always `.llml`. Never `.py`, `.txt`, or other extensions.
- **Encoding**: UTF-8.
- **Line endings**: LF (Unix).
- **Indentation**: 4 spaces or 1 tab — must be consistent throughout the file.
- **Case-sensitive**: `name` and `Name` are different variables.
- **Whitespace-sensitive**: Indentation indicates block structure (like Python).

### 2. Comments

```
// This is a single-line comment — agent ignores it

/*
  This is a multi-line comment
  — also ignored by the agent
*/
```

### 3. Meta-Instructions (`@rule`)

Top-level comments prefixed with `// @rule:` become behavioral rules for the agent:

```
// @rule: before modifying any file, check if it exists and show a diff
// @rule: when running destructive commands, ask the user for confirmation
// @rule: if a command fails, always capture stderr and show it to the user
```

Rules are advisory, global, and agent-interpreted. Always include safety rules
when writing `.llml` files that involve destructive operations.

### 4. Variables

Variables are labels for values in the agent's working memory.

```
project_root = "/home/user/my-project"
max_retries = 3
last_commit_hash = ""
```

**Type annotations** (advisory, never enforced):

```
server: remote host = "192.168.1.100"
port: number = 3000
debug_mode: boolean = true
current_branch: git branch = "main"
```

Valid types: `number`, `string`, `boolean`, `text`, or any natural-language
descriptor (`remote host`, `git branch`).

**Variable interpolation** — use `$varname` or `${varname}` in strings/commands:

```
ls -la $project_root
print("deploying to " + env + "...")
```

### 5. Literals & Data Types

| Type | Examples | Notes |
|------|----------|-------|
| String | `"hello"`, `"port: " + port` | Double-quoted. `+` concatenates. |
| Number | `3`, `3000`, `3.14` | Integer and float. |
| Boolean | `true`, `false` | Lowercase. |
| Null/Empty | `""` | Use empty string for unset. |
| JSON Object | `{ "key": "value" }` | Keys MUST be double-quoted. |
| JSON Array | `["api", "worker"]` | No trailing commas. |

**Type coercion**: `+` coerces numbers to strings. Non-empty values are truthy.

### 6. Operators

| Operator | Purpose | Example |
|----------|---------|---------|
| `+` | Addition / string concat | `count + 1`, `"a" + "b"` |
| `-` | Subtraction | `count - 1` |
| `*` | Multiplication | `retries * 2` |
| `/` | Division | `total / count` |
| `%` | Modulo | `value % 2` |
| `==` | Structural equality | `env == "production"` |
| `!=` | Structural inequality | `env != "production"` |
| `<` `>` `<=` `>=` | Comparison | `count > 0` |
| `~=` | **Semantic match (fuzzy)** | `err ~= "connection issue"` |
| `is` | Identity/type check | `x is number`, `file is about AI` |
| `in` | Membership / iteration | `"api" in config`, `for x in items` |

**`~=` is LLML's signature operator.** It is a semantic classifier, not a string
comparison. Use it when you want the agent to judge whether something *matches a
concept*, not an exact value.

- ✅ `error_msg ~= "connection error"` — semantic judgment
- ❌ `env ~= "production"` — use `==` for exact values
- ✅ `env == "production"` — exact comparison

### 7. Agent Actions

**Bash commands** — literal shell commands the agent executes:

```
ls -la $project_root
git status
npm test
rsync -avz dist/ user@server:/var/www
```

**Natural-language actions** — the agent interprets intent:

```
investigate the recent spike in 500 errors
find all large files modified in the last 6 months
```

Mix both freely based on which is more precise.

### 8. Control Flow

**`if` / `else if` / `else`**:

```
if file_exists($project_root + "/package.json") {
    npm install
    npm run build
} else if file_exists("Makefile") {
    make
} else {
    print("no build file found")
}
```

**`for` loops** — iterate over command output or list variables:

```
for file in ls *.js {
    npx eslint --fix $file
}

for service in config.services {
    curl -f $config.health_endpoints[service]
}
```

### 9. The `when` Keyword — State-Based Branching

Use `when` for routing based on semantic classification of state:

```
when $system_state ~= "healthy" {
    df -h
    uptime
} else when $system_state ~= "degraded" {
    investigate()
} else when $system_state ~= "down" {
    alert_oncall("system is down")
    emergency_recovery()
} else {
    print("unknown state — asking user")
    ask_user("unrecognized system state. how to proceed?")
}
```

### 10. Functions

Define reusable agent behavior templates:

```
deploy(env) {
    print("deploying to " + env + "...")
    npm run build
    if env == "production" {
        rsync -avz dist/ user@prod-server:/var/www/app
        ssh user@prod-server "systemctl restart app"
    } else {
        rsync -avz dist/ user@staging-server:/var/www/app-staging
    }
}

rollback(version) {
    print("rolling back to version " + version)
    ssh user@prod-server "docker pull app:" + version
    ssh user@prod-server "docker-compose up -d"
}
```

Call them:

```
deploy("staging")
rollback("previous")
```

Properties:
- Functions are **recorded** on definition, executed on call
- Support recursion (e.g., retry patterns)
- Parameters are positional
- No explicit return type

### 11. The `.tip()` Hint System

Attach `.tip(text)` to guide how the agent performs an action:

```
cleanup_temp_files() .tip(remove .tmp files older than 7 days, use find -mtime)
migrate_database() .tip(this is destructive — ask user for confirmation)
npm run lint .tip(fix auto-fixable issues with --fix)
return .tip(stop the pipeline here)
send_email(to, subject, body) .tip(use curl to send via SMTP)
```

Tips attach to: function calls, bash commands, `return` statements.

### 12. Classes

Define structured agent behaviors with state and methods:

```
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

    health_check() .tip(run the appropriate check) {
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

Instantiation:

```
api = new ServiceManager("nginx")
api.start()
api.health_check()
```

Rules:
- `constructor()` is special — called on `new`
- `this` refers to the current instance
- Properties need type annotations (`name: type = default`)
- No inheritance in v0.1

### 13. Pipelines

Multi-step workflows:

```
pipeline: concept = "CI/CD deployment"

step("lint") {
    npm run lint .tip(fix auto-fixable issues with --fix)
}

step("test") {
    npm run test:coverage
    if $test_results ~= "tests failed" {
        print("tests failed — aborting")
        return .tip(stop the pipeline here)
    }
}

step("build") {
    npm run build
    if $build_output ~= "build failed" {
        return
    }
}

step("deploy") {
    deploy("production")
}

pipeline.run()
```

Rules:
- `step()` blocks are defined before `pipeline.run()`
- Steps execute in definition order
- `return` inside a step halts the pipeline
- The optional `pipeline: concept = "..."` provides context

### 14. JSON Data Structures

```
config = {
    "services": ["api", "worker", "scheduler"],
    "health_endpoints": {
        "api": "http://localhost:3000/health",
        "worker": "http://localhost:3001/health"
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

### 15. User Interaction

**`ask_user(message)`** — pause and wait for user input:

```
ask_user("package update failed. how should I proceed?")
ask_user("where is the raw data file?")
```

**`confirm(message) { ... }`** — execute block only if user confirms:

```
confirm("are you sure you want to delete all logs?") {
    rm -rf /var/log/old/*
    print("logs cleared")
}
```

Natural-language checkpoints are also recognized:

```
before proceeding with the database migration, confirm with the user that they have a recent backup
```

### 16. Error Handling

**Checking exit codes**:

```
if $last_exit_code != 0 {
    // command failed — investigate
}
```

**Semantic error classification** with `when`:

```
if $last_exit_code != 0 {
    when $apt_error ~= "held broken packages" {
        apt --fix-broken install
        apt upgrade -y
    } else when $apt_error ~= "network issue" {
        print("network issue — retrying in 30s")
        sleep 30
        update_system() .tip(retry)
    } else {
        ask_user("unexpected error. how to proceed?")
    }
}
```

**Retry pattern** (function calls itself):

```
update_system() {
    apt update
    apt upgrade -y
    if $last_exit_code != 0 {
        sleep 30
        update_system() .tip(retry)
    }
}
```

### 17. Built-in Functions

| Function | Behavior |
|----------|----------|
| `print(message)` | Emit message to user. |
| `file_exists(path)` | Check if file exists. Returns `true`/`false`. |
| `ask_user(message)` | Pause and ask user for input. |
| `confirm(message) { ... }` | Ask for user confirmation before block. |
| `pipeline.run()` | Execute all defined `step()` blocks in order. |

### 18. Convention Functions (Agent-Interpreted)

| Function | Agent Behavior |
|----------|---------------|
| `investigate()` | Run diagnostics based on context |
| `alert_oncall(message)` | Notify on-call team (email, Slack, etc.) |
| `emergency_recovery()` | Execute emergency recovery |
| `analyze_test_failures()` | Inspect test output, identify failures |
| `analyze_build_errors()` | Inspect build output, identify errors |
| `send_email(to, subject, body)` | Send email (curl, mail, etc.) |

### 19. Implicit Variables

| Variable | Description |
|----------|-------------|
| `$last_exit_code` | Exit code of last command (0 = success) |
| `$result` | Result of last expression or command |
| `$test_results` | Output of last test run |
| `$build_output` | Output of last build command |
| `$smoke_results` | Output of last smoke test |
| `$apt_error` | Error output of last apt command |
| `$raw_data_preview` | Preview of a data file (first lines) |

---

## Writing Instructions

### Phase 1: Understand the User's Goal

1. Ask or determine:
   - What is the workflow? (deploy, data processing, system monitoring, CI/CD, etc.)
   - What tools/commands are involved?
   - What decisions need to be made? (conditionals, state-based routing)
   - What are the safety concerns? (destructive ops, external systems)
   - Should it be interactive or automated? (user checkpoints needed?)
   - Who is the audience? (agent executing it, human reading it)

2. Map the workflow to LLML constructs:

| If the user wants... | Use... |
|----------------------|--------|
| A simple sequence of commands | Top-level agent actions (bash + natural language) |
| Reusable procedure with parameters | `function` |
| Conditional behavior | `if`/`else` or `when` |
| Repeated actions | `for` loop |
| Complex state with multiple outcomes | `when` with `~=` |
| Object-like grouping of related behaviors | `class` |
| Multi-step workflow | `pipeline` with `step()` |
| Semantic judgment by agent | `~=` operator |
| Extra guidance for the agent | `.tip()` hints |
| Human safety check | `confirm()` or `ask_user()` |
| Structured data | JSON objects/arrays |
| Error recovery | `$last_exit_code` + `when` + retry |
| Behavioral guardrails | `// @rule:` meta-instructions |

### Phase 2: Plan the File Structure

For simple files (under 50 lines):

```
// @rule: (safety rules)
// @rule: ...

// variables
env = "staging"

// direct actions
npm run build

// conditionals
if env == "production" {
    rsync ...
}
```

For complex files (functions, classes, pipelines):

```
// @rule: (safety rules)
// @rule: ...

// ── Configuration ──
config = { ... }
env = "staging"

// ── Helper Functions ──
deploy(env) { ... }
rollback(version) { ... }

// ── Classes ──
class ServiceManager { ... }

// ── Pipeline ──
step("name") { ... }
pipeline.run()

// ── Main Execution ──
deploy(env)
```

### Phase 3: Write the LLML File

Follow these rules when composing LLML:

**General style rules:**
- Use section comments (`// ── Section Name ──`) to organize large files
- One statement per line (don't chain commands with `&&` — spell them out)
- Prefer `snake_case` for variable and function names
- Prefer `CapitalCase` for class names
- Keep lines under 100 characters when possible
- Use consistent indentation (4 spaces recommended)

**Variable rules:**
- Use descriptive names: `deployment_target`, not `dt`
- Add type annotations for non-obvious types: `server: remote host = "..."`
- Define variables at the top or at the start of their scope

**When to use which operator:**
- **`==`**: For exact, known values (`env == "production"`)
- **`~=`**: For conceptual/semantic matching (`error_msg ~= "connection issue"`)
- **`is`**: For identity/type checks (`x is number`, `file is about AI`)

**Error handling rules:**
- Always check `$last_exit_code` after risky commands (builds, deploys, deletes)
- Use `when` with `~=` to classify different error types
- Always have a fallback `else` or `ask_user()` for unrecognized errors
- For retryable failures, have the function call itself after a delay

**Safety rules:**
- Always add `// @rule:` meta-instructions for safety
- Wrap destructive commands in `confirm()` blocks
- Use `.tip()` to warn about danger: `.tip(this is destructive — ask first)`

### Phase 4: Review Before Saving

Before writing the file, check:

1. **Syntax**: Are all braces matched? Strings closed? JSON valid?
2. **Completeness**: Are all referenced variables defined? Are all functions/classes used?
3. **Safety**: Are destructive operations guarded with `confirm()` or `@rule`?
4. **Clarity**: Would a human reader understand the intent? Are `.tip()` hints present where the agent might be ambiguous?
5. **Executability**: If the file were run, would it produce the desired outcome?

Optionally run `llml-lint` on the result for a formal validation.

### Phase 5: Save the File

Use the `write` tool to save the `.llml` file to the specified path. If no path
is given, use `./<name>.llml` in the current working directory.

---

## Templates

### Template 1: Simple Procedure

````llml
// @rule: if a command fails, show the error and ask the user
// @rule: before modifying files, confirm with the user

// ── Configuration ──
target_env = "staging"
project_root = "/path/to/project"

// ── Steps ──
print("starting deployment to " + target_env)
cd $project_root

npm install
npm run build

if target_env == "production" {
    confirm("deploy to production?") {
        rsync -avz dist/ user@prod-server:/var/www/app
        ssh user@prod-server "systemctl restart app"
    }
} else {
    rsync -avz dist/ user@staging-server:/var/www/app-staging
}

print("deployment complete!")
````

### Template 2: Function-Based Workflow

````llml
// @rule: before any destructive operation, confirm with the user
// @rule: if a command fails, capture stderr and investigate

// ── Configuration ──
project_root = "/home/user/app"
remote_user = "deploy"
servers = {
    "staging": "staging.example.com",
    "production": "prod.example.com"
}

// ── Functions ──

build() {
    print("building project...")
    cd $project_root
    npm install
    npm run build
    if $last_exit_code != 0 {
        analyze_build_errors()
        return .tip(stop — build failed)
    }
    print("build successful")
}

deploy(env) {
    server = servers[env]
    print("deploying to " + env + " (" + server + ")")
    rsync -avz $project_root/dist/ user@$server:/var/www/$env
    if $last_exit_code != 0 {
        print("deploy failed for " + env)
        ask_user("deploy failed. retry or abort?")
    } else {
        print("deploy to " + env + " complete")
    }
}

health_check(env) {
    server = servers[env]
    print("checking " + env + "...")
    curl -f http://$server/health
    if $result ~= "service unhealthy" {
        alert_oncall(env + " is down on " + server)
    }
}

// ── Main ──
target = "staging"
build()
deploy(target)
health_check(target)
````

### Template 3: Pipeline (CI/CD)

````llml
// @rule: if any step fails, do not proceed to the next step
// @rule: before deploying to production, confirm with the user

// ── Configuration ──
env = "staging"

// ── Pipeline ──

pipeline: concept = "build, test, and deploy"

step("install") {
    print("installing dependencies...")
    npm install
}

step("lint") {
    print("linting...")
    npm run lint .tip(fix auto-fixable issues with --fix)
}

step("test") {
    print("running tests...")
    npm test
    if $test_results ~= "tests failed" {
        analyze_test_failures()
        return .tip(stop — tests failed)
    }
}

step("build") {
    print("building...")
    npm run build
    if $build_output ~= "build failed" {
        analyze_build_errors()
        return .tip(stop — build failed)
    }
}

step("deploy") {
    if env == "production" {
        confirm("deploy to production?") {
            rsync -avz dist/ prod-server:/var/www/app
        }
    } else {
        rsync -avz dist/ staging-server:/var/www/app-staging
    }
}

step("smoke_test") {
    print("running smoke tests...")
    if env == "production" {
        curl -f https://prod.example.com/health
    } else {
        curl -f https://staging.example.com/health
    }
    if $result ~= "endpoint unhealthy" {
        print("smoke test failed! rolling back...")
        rollback("previous")
        return
    }
    print("all checks passed!")
}

// ── Execute ──
pipeline.run()
````

### Template 4: Class-Based Service Management

````llml
// @rule: when running system commands, check for sudo if needed
// @rule: if a service fails to start, collect logs and show them

// ── Configuration ──
services_list = ["nginx", "postgresql", "redis"]

// ── Class ──

class ServiceManager {
    name: text
    pid: number = -1
    log_path: text = "/var/log"

    constructor(name) {
        this.name = name
        this.log_path = "/var/log/" + name + "/"
    }

    start() {
        print("starting " + this.name + "...")
        systemctl start $this.name
        if $last_exit_code != 0 {
            print("failed to start " + this.name)
            journalctl -u $this.name -n 20 --no-pager
            ask_user(this.name + " failed to start. investigate?")
        } else {
            this.pid = pgrep -f $this.name
            print(this.name + " started (PID: " + this.pid + ")")
        }
    }

    stop() {
        print("stopping " + this.name + "...")
        systemctl stop $this.name
        this.pid = -1
    }

    restart() {
        print("restarting " + this.name + "...")
        this.stop()
        this.start()
    }

    status() {
        systemctl is-active $this.name
        if $result ~= "active" {
            print(this.name + " is running")
        } else {
            print(this.name + " is NOT running")
            journalctl -u $this.name -n 10 --no-pager
        }
    }
}

// ── Main ──
for service_name in services_list {
    service = new ServiceManager(service_name)
    service.status()
}
````

### Template 5: Data Processing Pipeline

````llml
// @rule: before overwriting any output file, confirm with user
// @rule: if data parsing fails, show a preview and ask user

// ── Configuration ──
raw_data_path = "./data/raw/source.csv"
clean_data_path = "./data/clean/output.json"

// ── Functions ──

inspect_input() {
    if file_exists($raw_data_path) {
        print("found input at " + raw_data_path)
        head -5 $raw_data_path
        wc -l $raw_data_path
        file $raw_data_path
    } else {
        print("error: " + raw_data_path + " not found")
        ask_user("where is the input file?")
    }
}

process_csv() {
    print("processing CSV data...")

    when $raw_data_preview ~= "has header row" {
        python3 -c "
import csv, json
with open('$raw_data_path') as f:
    reader = csv.DictReader(f)
    rows = list(reader)
with open('$clean_data_path', 'w') as f:
    json.dump(rows, f, indent=2)
"
    } else when $raw_data_preview ~= "tab-separated" {
        python3 -c "
import csv, json
with open('$raw_data_path') as f:
    reader = csv.DictReader(f, delimiter='\t')
    rows = list(reader)
with open('$clean_data_path', 'w') as f:
    json.dump(rows, f, indent=2)
"
    } else {
        print("unrecognized format")
        ask_user("how should I parse this data?")
        return .tip(stop — need user guidance)
    }

    if $last_exit_code != 0 {
        print("processing failed")
        ask_user("conversion failed. how to proceed?")
    }
}

validate_output() {
    if file_exists($clean_data_path) {
        print("output written to " + clean_data_path)
        wc -c $clean_data_path
        python3 -c "
import json
data = json.load(open('$clean_data_path'))
print(f'{len(data)} records written')
"
    } else {
        print("error: output file not created")
    }
}

// ── Main ──
inspect_input()
process_csv()
validate_output()
print("data pipeline complete")
````

### Template 6: Monitoring / Investigation Script

````llml
// @rule: always show raw diagnostic output to the user
// @rule: if a critical issue is found, alert immediately

// ── Configuration ──
services_to_check = ["api", "worker", "scheduler"]
alert_email = "ops@example.com"

// ── Functions ──

check_system() {
    print("=== System Health Check ===")
    df -h
    print("---")
    free -h
    print("---")
    uptime
    print("---")
    top -b -n 1 | head -15
}

check_services() {
    for service in services_to_check {
        systemctl is-active $service

        when $result ~= "active" {
            print("  ✅ " + service + " is running")
        } else when $result ~= "inactive" {
            print("  ⚠️ " + service + " is inactive — restarting")
            systemctl restart $service
        } else when $result ~= "failed" {
            print("  🚫 " + service + " has FAILED")
            journalctl -u $service -n 30 --no-pager
            alert_oncall(service + " has failed on " + hostname)
        } else {
            print("  ❓ " + service + " status unknown")
            journalctl -u $service -n 10 --no-pager
        }
    }
}

check_disk_space() {
    df -h | grep -E "(9[0-9]%|100%)"
    if $result ~= "disk is nearly full" {
        print("⚠️ WARNING: disk space critically low")
        alert_oncall("disk space critically low on " + hostname)
    }
}

// ── Main ──
hostname = "server-01"
print("investigating " + hostname + "...")
check_system()
check_services()
check_disk_space()
print("investigation complete")
````

---

## Best Practices

### ✅ Do

- **Use `// @rule:` at the top** of every file for safety guardrails
- **Prefer `==` for exact comparisons**, `~=` for semantic/concept matching
- **Wrap destructive commands** in `confirm()` blocks
- **Check `$last_exit_code`** after risky operations
- **Use `.tip()` hints** wherever the agent's default judgment might be ambiguous
- **Use `when` with `~=`** for state-based routing with multiple outcomes
- **Use `snake_case`** for variables and functions, `CapitalCase` for classes
- **Organize with section comments** (`// ── Config ──`) in files over 30 lines
- **Add type annotations** on variables where the type isn't obvious from context
- **Handle errors gracefully** — classify with `when`, retry when appropriate, fallback to user otherwise

### ❌ Don't

- ❌ **Don't use `~=` for exact values** — use `==` instead (`env ~= "production"` is wrong)
- ❌ **Don't mix indent styles** (tabs + spaces) — pick one and be consistent
- ❌ **Don't omit braces** around `if`/`for`/`when` bodies — they are required
- ❌ **Don't chain commands with `&&`** — write them on separate lines so the agent can check `$last_exit_code` between them
- ❌ **Don't hardcode secrets** (passwords, API keys, tokens) in `.llml` files — use `ask_user()` or environment variables
- ❌ **Don't write overly long lines** (>120 chars) — break them up
- ❌ **Don't assume a specific shell** (bash vs zsh) — prefer portable commands
- ❌ **Don't put `@rule` comments inside functions/classes** — they must be at top level
- ❌ **Don't use trailing commas** in JSON objects/arrays — they break the structure
- ❌ **Don't forget the file extension** — must be `.llml`

---

## Examples

### Example 1: User says "write an .llml that builds and deploys my static site"

The agent would produce something like Template 2 (Function-Based Workflow)
with `npm run build` and `rsync` to a server, including:
- Error handling on build failure
- `confirm()` before production deploy
- `@rule` safety meta-instructions

### Example 2: User says "I need an .llml to check if my servers are healthy"

The agent would produce something like Template 6 (Monitoring Script) with:
- Service status checks
- Disk space monitoring
- Semantic classification of service states with `when`
- Alert oncall for failures

### Example 3: User says "convert this bash script to LLML"

Given a bash script:
```bash
#!/bin/bash
cd /home/user/app
npm install
npm test
if [ $? -eq 0 ]; then
  npm run build
  rsync -avz dist/ server:/var/www
fi
```

The agent would write:
```llml
// @rule: if a command fails, capture stderr and show it
// @rule: before deploying, confirm with the user

project_root = "/home/user/app"

cd $project_root
npm install
npm test

if $test_results ~= "tests passed" {
    npm run build
    confirm("deploy build to production?") {
        rsync -avz dist/ server:/var/www
    }
} else {
    analyze_test_failures()
    print("deployment aborted due to test failures")
}
```

---

## Edge Cases & Gotchas

| Situation | Guidance |
|-----------|----------|
| **User wants a very simple script** (<5 lines) | Don't over-engineer with functions/classes. Direct agent actions + simple `if` is fine |
| **User wants a complex workflow** (>100 lines) | Use functions and pipelines. Organize with section comments |
| **User doesn't specify file path** | Save as `./<descriptive-name>.llml` in the current directory |
| **User wants interactive behavior** | Use `confirm()` and `ask_user()` at decision points |
| **User wants fully automated behavior** | Omit `confirm()` (add `@rule` for safety instead). Handle errors with retry patterns |
| **User provides existing code in another language** | Translate the logic to LLML constructs. Bash → agent actions. Python → semantics |
| **User wants to include secrets** | Never write secrets. Use `ask_user("enter the API key")` and store in variable |
| **Multiple output formats** | If the user wants JSON + CSV + summary, write separate steps or use functions |
| **Cross-platform deployment** | Use portable commands (`curl`, `rsync`, `ssh`, `docker`) and note assumptions |
| **Circular dependencies in calls** | Functions can call each other (recursion valid) but ensure exit conditions |
| **User changes requirements mid-write** | Ask if they want to restart or patch the existing file |
| **Writing a library of reusable LLML** | Put each major feature in its own `.llml` file. Use functions without top-level calls |
