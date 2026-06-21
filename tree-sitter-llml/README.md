# tree-sitter-llml

[Tree-sitter](https://tree-sitter.github.io/) grammar for **LLML** (LLM Language) — a behavioral specification language for LLM-based agents.

## Quick Start

```bash
# Install tree-sitter-cli if you haven't already
npm install -g tree-sitter-cli

# Generate the C parser from grammar.js
tree-sitter generate

# Build the WASM parser (for use in web/VS Code)
tree-sitter build --wasm

# Try it on an example file
tree-sitter parse example.llml

# Highlight a file (preview colors in terminal)
tree-sitter highlight example.llml

# Run tests
tree-sitter test
```

## Editor Setup

### Neovim (via nvim-treesitter)

Add to your Neovim config:

```lua
local parser_config = require("nvim-treesitter.parsers").get_parser_configs()

parser_config.llml = {
  install_info = {
    url = "/path/to/tree-sitter-llml",
    files = { "src/parser.c" },
    -- For WASM:
    -- wasm_url = "https://github.com/you/tree-sitter-llml/releases/download/v0.1/tree-sitter-llml.wasm"
  },
  filetype = "llml",
}

-- Register the filetype
vim.cmd([[
  au BufRead,BufNewFile *.llml set filetype=llml
]])
```

Then `:TSInstall llml` and `:TSEnable highlight`.

### VS Code

1. Build the WASM parser: `tree-sitter build --wasm`
2. Use the `tree-sitter` VS Code extension to load the generated `tree-sitter-llml.wasm`
3. Or bundle it into a custom VS Code extension

### Helix

Add to `languages.toml`:

```toml
[[language]]
name = "llml"
scope = "source.llml"
file-types = ["llml"]
comment-token = "//"
indent = { tab-width = 4, unit = "    " }

[[grammar]]
name = "llml"
source = { path = "/path/to/tree-sitter-llml" }
```

## What Gets Highlighted

| Feature | Highlight Group |
|---|---|
| `//` comments | `@comment` |
| `// @rule:` meta-instructions | `@comment.special` |
| Strings `"..."` | `@string` |
| `$var` / `${var}` interpolation | `@string.special.symbol` |
| Numbers, booleans | `@number`, `@boolean` |
| `if`, `else`, `for`, `when`, `return`, `class`, etc. | `@keyword` |
| `~=`, `==`, `!=`, `+`, `-`, `*`, `/`, etc. | `@operator` |
| Function calls `foo()` | `@function.call` |
| Built-in: `print()`, `ask_user()` | `@function.builtin` |
| Function definitions | `@function` |
| Method definitions | `@method` |
| Class names | `@type` |
| Property access `.name` | `@property` |
| `.tip()` hints | `@comment.special` |
| JSON keys | `@property` |

## Grammar Structure

- **`grammar.js`** — DSL grammar definition
- **`src/parser.c`** — Generated C parser (portable, fast)
- **`queries/highlights.scm`** — S-expression queries for syntax highlighting
- **`queries/folds.scm`** — Code folding regions
- **`queries/indents.scm`** — Indentation rules
- **`queries/locals.scm`** — Scope/definition tracking (for future LSP features)
- **`test/corpus/*.llml`** — Test cases

## Design Decisions

- **Indentation + braces**: LLML uses `{}` blocks, so we use braces as block delimiters rather than implementing a full Python-style indentation tracker. This is simpler and sufficient for highlighting.
- **Catch-all fallthrough**: Natural-language actions and bash commands that don't match structured syntax become plain text (no highlight). This is intentional — the structured parts are what need highlighting.
- **JSON inline**: JSON objects/arrays are parsed inline rather than embedding `tree-sitter-json`, keeping the grammar self-contained.
- **`.tip()` as suffix**: Tips are parsed as an optional suffix on any call expression, allowing `action() .tip(...)`.
