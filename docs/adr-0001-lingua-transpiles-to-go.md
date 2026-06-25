# ADR 0001: Lingua is a transpiled language targeting Go

Date: 2026-06-24
Status: Proposed

## Context

Lingua is currently a specification draft with no implementation. Its design
already mirrors Go in most load-bearing areas:

| Lingua feature | Go equivalent | Fit |
|---|---|---|
| `package main`, `import (...)` | identical | exact |
| `//`, `/* */` comments | identical | exact |
| `x: integer = 10`, `x := 10` | `x int = 10`, `x := 10` | trivial rename |
| `*integer`, `&x`, `*p` | identical | exact |
| `function f(a, b: int): int { }` | `func f(a, b int) int { }` | keyword swap |
| `struct`, `interface` (structural) | identical | exact |
| `channel[int]`, `ch <- 10`, `<-ch` | `chan int` | near-exact |
| `run fn() { }()` | `go func() { }()` | near-exact |
| `switch` / `if` / `else if` | close | compatible |
| `Box[T]`, `[T: Comparable]` | Go 1.18 generics | compatible |
| `type UserId integer` | `type UserId int` | exact |
| `alias int integer` | Go 1.9 type aliases (`type int = integer`) | exact |
| `any` | Go 1.18 `any = interface{}` | works |
| `constant PI` | `const PI` | exact |
| `public` / private-by-default | Go capitalization | mechanical |
| `error` interface | Go `error` | compatible |
| events ("using channels and tasks") | channels + goroutines | matches spec |

Building a from-scratch language for a single author means re-implementing a
GC, a goroutine-like scheduler, a channel runtime, generics, a stdlib, and a
tooling story (LSP, debugger, profiler). Go already has all of these, mature
and battle-tested. Transpiling to Go is the same strategy used by
TypeScript→JS, Kotlin→JVM, and Nim→C/JS: trade implementation effort for
ecosystem leverage.

## Decision

**Lingua will be implemented as a transpiled language that emits Go.** A Lingua
program is expanded (macros) and lowered to Go source, then compiled with
`go build`. The implementation is a transpiler front-end, not a standalone
compiler/runtime.

Consequences of this decision:

1. **Go is the compilation target, not a peer language.** Lingua code is never
   interpreted; it always becomes Go.
2. **A `gostd` dialect makes "accept Go code" true.** Go keywords are valid
   Lingua via the alias system (`alias func function`, `alias const constant`,
   `alias chan channel`, `alias go run`, `alias int integer`, ...). A `.go`
   file is then a Lingua file written in the `gostd` dialect. This is exactly
   what `alias` was designed for, and it retroactively justifies the feature.
3. **Macros are the transpiler's first phase** (expand → lower to Go →
   `go build`). They are a front-end concern; Go has no macro system and none
   is needed.
4. **Custom operators are lowered at transpile time.** The spec already says
   operator resolution occurs at compile time. The transpiler resolves
   precedence and emits fully-parenthesized function calls: `a ~= b` →
   `OpTildeEqual(a, b)`. Lingua source keeps the operator syntax; generated Go
   is plain function calls.
5. **`class` maps to a pointer-receiver struct + generated constructor.**
   `struct` maps to a value struct. The value/reference distinction from
   spec §10 survives at the Lingua source level.
6. **Design by Contract is lowered to Go checks:**
   - `require` → entry `if !cond { panic }`
   - `ensure` → `defer` check
   - `invariant` → entry/exit checks
7. **`can` is limited to `require` + invariants only.** It never runs the
   function body. This resolves the existing spec contradiction where
   `ensure result > x` would require executing the body while `can` "does not
   execute normal program behavior." Postconditions are out of `can`'s scope.
8. **Purity starts as documentation-only**, with conservative transpiler-side
   static analysis added later. Purity enforcement is not a launch blocker.
9. **Reactive state, state machines, decorators, and events** are backed by a
   small `lingua/runtime` Go package plus generated wrappers. This is library
   work, not language work.
10. **Debugging UX needs a plan.** Go stack traces, `delve`, and `pprof` will
    show generated Go, not Lingua. The transpiler should preserve names where
    possible and provide source mapping. Generated-code compiler errors must
    be caught and re-emitted at the Lingua level.
11. **Pin a Go version** and track Go releases as a maintenance policy
    (generics in 1.18, range-over-func in 1.23, etc.). Lingua inherits Go's
    evolution cycle, like TypeScript tracks ECMAScript.

## What this buys

- GC, scheduler, channels, generics, stdlib for free.
- Tooling: `gopls`, `delve`, `pprof`, race detector, benchmarks, `go test`.
- The entire Go package ecosystem.
- A credible implementation path for LLML: `prompt()`, `~=`, and `Agent`
  become a Go runtime library calling an LLM SDK. "Interpreter TBD" becomes
  "library + transpiler."
- Months-to-implementation instead of years.

## What this costs

- No from-scratch runtime; the value/reference class distinction exists only
  at the source level.
- Operator syntax lives in Lingua source, not generated Go.
- Debugging transparency requires explicit effort (source maps, name
  preservation).
- Cryptic Go compiler errors on generated code, unless the transpiler
  validates first and emits Lingua-level errors.
- Maintenance burden of tracking Go releases.

## Prior art

- **TypeScript → JavaScript** — superset + types, ecosystem leverage. Closest
  model.
- **Kotlin → JVM** — pragmatic language on a mature runtime.
- **Nim → C/JS** — transpilation plus a declarative macro system similar to
  Lingua §24.
- **Go's own `go generate` + `text/template`** — the already-accepted Go
  codegen mechanism the transpiler slots into.

## Open questions

- Exact Go version pin and release-tracking policy.
- Source-map / debug-info format for mapping generated Go back to Lingua.
- Whether `.go` files import verbatim or must pass through the `gostd`
  dialect parse.
- Scope of the initial `lingua/runtime` package (events, reactive state,
  state machines, decorators — all at once or incrementally).
