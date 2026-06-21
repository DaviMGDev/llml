; ── LLML Tree-sitter Highlight Queries ──────────────────────────────
; Captures follow the standard Tree-sitter convention for Neovim/Helix.

; ── Comments ────────────────────────────────────────────────────────
(comment) @comment @spell

; @rule meta-instructions
(meta_rule) @comment.special

; ── Literals ────────────────────────────────────────────────────────
(string) @string

; Variable interpolation inside strings
(interpolation) @string.special.symbol

(number) @number
(boolean) @boolean

; ── Variables ───────────────────────────────────────────────────────
(identifier) @variable

; $variable references
(variable_ref) @variable.builtin

"this" @variable.builtin

; ── Keywords ────────────────────────────────────────────────────────
[
  "if"
  "else"
  "for"
  "in"
  "when"
  "return"
  "class"
  "constructor"
  "new"
  "step"
  "pipeline"
  "is"
  "run"
] @keyword

; ── Operators ───────────────────────────────────────────────────────
[
  "="
  "+"
  "-"
  "*"
  "/"
  "%"
] @operator

[
  "=="
  "!="
  "<"
  ">"
  "<="
  ">="
] @operator

; Semantic operators
[
  "~="
  "is"
  "in"
] @keyword.operator

"." @operator

; ── Punctuation ─────────────────────────────────────────────────────
"(" @punctuation.bracket
")" @punctuation.bracket
"[" @punctuation.bracket
"]" @punctuation.bracket

"," @punctuation.delimiter
":" @punctuation.delimiter

; ── Block Boundaries ────────────────────────────────────────────────
"{" @punctuation.bracket
"}" @punctuation.bracket

; ── Tips ────────────────────────────────────────────────────────────
(tip) @comment.special

; ── Function / Call ──────────────────────────────────────────────────
(function_definition
  name: (identifier) @function)

(method_definition
  name: (identifier) @method)

; Parameter identifiers in function/method definitions
(function_definition
  (identifier) @parameter)

(method_definition
  (identifier) @parameter)

; ── Class names ─────────────────────────────────────────────────────
(class_definition
  name: (identifier) @type)

(property_definition
  (identifier) @property)

; ── Method (inside class) ───────────────────────────────────────────
(method_definition
  . (identifier) @method)

; ── Control flow ────────────────────────────────────────────────────
(if_statement
  "if" @keyword)

(for_statement
  "for" @keyword)

(when_statement
  "when" @keyword)

(else_clause
  "else" @keyword)

(when_else_clause
  "else" @keyword)
