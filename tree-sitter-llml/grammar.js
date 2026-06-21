/**
 * Tree-sitter grammar for LLML (LLM Language)
 *
 * A pragmatic highlighting grammar. 
 *
 * Key design: { } are NOT valid inside token streams — they're reserved
 * for block boundaries. This means repeat($.token) before a $.block
 * naturally stops at '{', making brace-delimited constructs parse
 * unambiguously.
 *
 * Everything else (bash commands, natural language, simple expressions)
 * is parsed as flat tokens. For syntax highlighting, the token type is
 * all that matters — tree structure is secondary.
 */

/// <reference types="tree-sitter-cli/dsl.d.ts" />

module.exports = grammar({
  name: 'llml',

  extras: $ => [
    /\s/,
  ],

  conflicts: $ => [
    // Structured blocks vs plain tokens — keywords and identifiers
    // that could start either.
    [$.if_statement, $.token],
    [$.for_statement, $.token],
    [$.when_statement, $.token],
    [$.function_definition, $.token],
    [$.class_definition, $.token],
    [$.step_definition, $.token],
    [$.confirm_block, $.token],
    // else-if and else-when chaining
    [$.if_statement],
    [$.when_statement],
  ],

  rules: {
    // ── Top Level ──────────────────────────────────────────────────────
    source_file: $ => repeat(choice(
      $.meta_rule,
      $.comment,
      $.if_statement,
      $.for_statement,
      $.when_statement,
      $.function_definition,
      $.class_definition,
      $.step_definition,
      $.confirm_block,
      $.token,
    )),

    // ── Comments ───────────────────────────────────────────────────────
    comment: $ => token(choice(
      seq('//', /[^\n]*/),
      seq('/*', /[^*]*\*+([^/*][^*]*\*+)*/, '/'),
    )),

    meta_rule: $ => token(seq('//', /@rule:[^\n]*/)),

    // ── Literals ───────────────────────────────────────────────────────
    string: $ => seq(
      '"',
      repeat(choice(
        /[^"$\\]+/,
        /\\[\\"ntr0]/,
        $.interpolation,
      )),
      '"',
    ),

    interpolation: $ => token(choice(
      seq('$', /[a-zA-Z_][a-zA-Z0-9_]*/),
      seq('${', /[^}]*/, '}'),
    )),

    number: $ => token(choice(/\d+\.\d+/, /\d+/)),
    boolean: $ => choice('true', 'false'),

    // ── Identifiers & Variables ────────────────────────────────────────
    identifier: $ => /[a-zA-Z_][a-zA-Z0-9_]*/,
    variable_ref: $ => token(seq('$', /[a-zA-Z_][a-zA-Z0-9_]*/)),

    // ── Keywords & Operators ───────────────────────────────────────────
    keyword: $ => choice(
      'if', 'else', 'for', 'in', 'when', 'return',
      'class', 'constructor', 'this', 'new',
      'step', 'pipeline', 'is', 'run',
    ),

    operator: $ => choice(
      '~=', '==', '!=', '<=', '>=',
      '=', '+', '-', '*', '/', '%',
      '<', '>', '.', '!',
    ),

    punctuation: $ => choice('(', ')', '[', ']', ',', ':'),

    // ── Tips ───────────────────────────────────────────────────────────
    tip: $ => seq('.tip(', /[^)]*/, ')'),

    // ── Single Token (catch-all) ───────────────────────────────────────
    // Lowest precedence. { } are NOT valid tokens — they're block
    // delimiters. This means repeat($.token) before a $.block in
    // if/for/when/function constructs naturally stops at '{'.
    token: $ => prec(-1, choice(
      $.string,
      $.number,
      $.boolean,
      $.variable_ref,
      $.interpolation,
      $.tip,
      $.keyword,
      $.operator,
      $.punctuation,
      $.identifier,
      $._other,
    )),

    _other: $ => /[^\s"'(){}\[\]\n]+/,

    // ── BLOCKS & STRUCTURED CONSTRUCTS ─────────────────────────────────

    block: $ => seq(
      '{',
      repeat(choice(
        $.comment,
        $.if_statement,
        $.for_statement,
        $.when_statement,
        $.step_definition,
        $.confirm_block,
        $.token,
      )),
      '}',
    ),

    if_statement: $ => prec(1, seq(
      'if',
      repeat($.token),
      $.block,
      repeat($.else_clause),
    )),

    else_clause: $ => seq(
      'else',
      choice(
        seq('if', repeat($.token), $.block),
        $.block,
      ),
    ),

    for_statement: $ => prec(1, seq(
      'for',
      repeat($.token),
      $.block,
    )),

    when_statement: $ => prec(1, seq(
      'when',
      repeat($.token),
      $.block,
      repeat($.when_else_clause),
    )),

    when_else_clause: $ => seq(
      'else',
      choice(
        seq('when', repeat($.token), $.block),
        $.block,
      ),
    ),

    function_definition: $ => prec(1, seq(
      $.identifier,
      '(',
      optional(seq($.identifier, repeat(seq(',', $.identifier)), optional(','))),
      ')',
      optional($.tip),
      $.block,
    )),

    class_definition: $ => prec(1, seq(
      'class',
      $.identifier,
      '{',
      repeat(choice(
        $.comment,
        $.property_definition,
        $.method_definition,
      )),
      '}',
    )),

    property_definition: $ => seq(
      $.identifier, ':', $.identifier,
    ),

    method_definition: $ => seq(
      $.identifier,
      '(',
      optional(seq($.identifier, repeat(seq(',', $.identifier)), optional(','))),
      ')',
      optional($.tip),
      $.block,
    ),

    step_definition: $ => prec(1, seq(
      'step', '(', $.string, ')', $.block,
    )),

    confirm_block: $ => prec(1, seq(
      'confirm', '(', $.string, ')', $.block,
    )),
  },
});
