# LLML — LLM Language

> A behavioral specification language for LLM-based agents.  
> The agent reads `.llml` files and *executes* them using real tools.

LLML is not a programming language — there's no compiler, no runtime, no interpreter. It's a **structured behavioral spec** that looks like code, reads like natural language, and is carried out by an intelligent agent. The agent *is* the runtime.

## Quick Example

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

deploy("staging")
```

When an agent reads this, it will: run `npm run build`, check the environment, `rsync` the built files, and restart the appropriate service — all using real shell commands, real SSH connections, and real file operations.

## Why LLML?

- **Structured guidance** — More precise than plain English, less rigid than actual code
- **Intentional ambiguity** — The `~=` operator lets the agent make semantic judgments
- **Human-in-the-loop** — Built-in `confirm()` and `ask_user()` points for safety
- **Real-world execution** — Commands like `rsync`, `systemctl`, and `curl` are executed, not simulated
- **Mixed paradigms** — Combines JSON data, natural language, conditionals, loops, classes, and pipelines

## Key Concepts

| Concept | Description |
|---|---|
| **Variables** | Track state the agent remembers. Optional type annotations are hints, not enforcement. |
| **Agent Actions** | Bash commands or natural-language directives the agent executes for real. |
| **`~=` Operator** | Semantic match — the agent judges whether a value matches a *concept* (not a string pattern). |
| **`when` Keyword** | State-based branching — routes agent decisions based on semantic classification. |
| **`.tip()` Hints** | Extra context that guides *how* the agent performs an action. |
| **Classes** | Structured agent behaviors with constructors, methods, and `this`. |
| **Pipelines** | Multi-step workflows using `step()` blocks and `pipeline.run()`. |
| **`@rule` Comments** | Meta-instructions the agent reads as behavioral guardrails. |
| **User Interaction** | `confirm()` and `ask_user()` for explicit human-in-the-loop checkpoints. |
| **Error Handling** | The agent gracefully recovers from failures using retries, `when`-based classification, and fallback to the user. |

## Getting Started

1. **Create a file** with the `.llml` extension
2. **Write your spec** using LLML syntax — variables, actions, conditionals, functions, etc.
3. **Give it to an agent** — an LLM-powered agent reads the file and carries out the instructions
4. **The agent executes** — runs real commands, reads real files, makes real decisions

> **File extension:** Always use `.llml`. Do **not** use `.py` — LLML is not valid Python (`~=`, `when`, `.tip()`, and natural-language actions are not Python syntax).

## Project Structure

```
llml/
├── example.llml    Comprehensive example covering all LLML features
├── SPEC.md         Full language specification
└── README.md       This file
```

## Learn More

- **[SPEC.md](./SPEC.md)** — Complete language specification with syntax, semantics, and detailed reference
- **[example.llml](./example.llml)** — Comprehensive 400-line example covering every LLML construct

## License

MIT — see [LICENSE](LICENSE).

Copyright (c) 2026 DaviMGDev
