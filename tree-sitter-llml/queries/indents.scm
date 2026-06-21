; ── Indentation ─────────────────────────────────────────────────────

(block "{" @indent.branch "}" @outdent.branch)

(function_definition
  body: (block) @indent.branch)

(class_definition) @indent.branch

(method_definition
  body: (block) @indent.branch)

(if_statement
  body: (block) @indent.branch)

(for_statement
  body: (block) @indent.branch)

(when_statement
  body: (block) @indent.branch)

(step_definition
  body: (block) @indent.branch)
