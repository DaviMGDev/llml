# Language Specification (Draft)

## 1. Philosophy

The language is intentionally verbose at its core.

The language is not intended to be used directly by most users. Instead, users are expected to create custom dialects using aliases and macros.

The verbose syntax exists to:

* simplify parsing
* simplify tooling
* improve readability
* provide a stable base for dialect creation

Example:

```txt
alias int integer
alias str string
alias fn function
```

After defining aliases, users may write:

```txt
x: int = 10

fn add(a, b: int): int {
    return a + b
}
```

---

# 2. Comments

Single-line comments:

```txt
// this is a comment
```

Multi-line comments:

```txt
/*
this is a comment
that spans multiple lines
*/
```

---

# 3. Packages

Every source file belongs to a package.

Syntax:

```txt
package main
```

Imports:

```txt
import (
    math
    strings
)
```

Single import:

```txt
import math
```

---

# 4. Declarations

Variables:

```txt
x: integer
```

Initialized variables:

```txt
x: integer = 10
```

Type inference:

```txt
x := 10
```

Constants:

```txt
constant PI: float = 3.14159
```

Constant inference:

```txt
constant gravity := 9.8
```

---

# 5. Built-in Types

The language provides the following built-in types.

## Numeric

```txt
integer
float
```

## Text

```txt
string
character
```

## Boolean

```txt
boolean
```

Values:

```txt
true
false
```

## Dynamic

```txt
any
```

Example:

```txt
value: any = 10

value = "hello"
```

## Void

```txt
void
```

Used for functions that do not return values.

## Pointer

```txt
p: *integer

p = &x
```

Dereference:

```txt
*p
```

## Function

Function types:

```txt
adder: function(integer, integer) integer
```

Example:

```txt
adder = function(a, b: integer): integer {
    return a + b
}
```

## Union Types

```txt
value: (integer | string)
```

Example:

```txt
value = 10

value = "hello"
```

---

# 6. Aliases

Aliases create alternative names for existing symbols.

Syntax:

```txt
alias int integer
alias str string
alias bool boolean
alias fn function
```

Aliases do not create new types.

Example:

```txt
x: int = 10
```

is equivalent to:

```txt
x: integer = 10
```

---

# 7. Type Definitions

Types create new distinct types.

Syntax:

```txt
type UserId integer
```

Example:

```txt
id: UserId = 10
```

The compiler treats `UserId` and `integer` as different types.

Types may have invariants.

Example:

```txt
type Natural integer

invariant Natural {
    this >= 0
}
```

---

# 8. Functions

Syntax:

```txt
function add(a, b: integer): integer {
    return a + b
}
```

No return value:

```txt
function printHello(): void {
    print("hello")
}
```

Anonymous functions:

```txt
adder := function(a, b: integer): integer {
    return a + b
}
```

Pure functions:

```txt
pure function square(x: int): int {
    return x * x
}
```

A `pure` function guarantees no side effects, no IO, and no mutation of outside state.
It may only call other pure functions. Non-pure functions may call pure functions freely.

---

# 9. Visibility

Everything is private by default.

Public declarations:

```txt
public function add(a, b: int): int {
    return a + b
}
```

```txt
public constant PI: float = 3.14159
```

---

# 10. Memory Model

## Structs

Structs are value types.

Assignment copies values.

Example:

```txt
struct Point {
    x: int
    y: int
}
```

Initialization:

```txt
p: Point = Point {
    x: 10
    y: 20
}
```

---

## Classes

Classes are reference types.

Instances are allocated on the managed heap.

Example:

```txt
class Person {
    age: int

    function init(age: int) {
        this.age = age
    }
}
```

Construction:

```txt
p := Person(20)
```

---

## Garbage Collection

Memory is managed by a tracing garbage collector.

The programmer never manually allocates or frees memory.

The collector may pause execution during collection.

The language does not use reference counting.

---

# 11. Interfaces

Interfaces define behavior contracts.

Syntax:

```txt
interface Printable {
    print(): void
}
```

Example:

```txt
printer: Printable = null
```

Implementation:

```txt
class ConsolePrinter {

    function print(): void {
        print("hello")
    }
}

```

Interface methods may be marked `pure`:

```txt
interface Hashable {
    pure function hash(): int
}
```

All implementations of a `pure` interface method must also satisfy the purity guarantees.

---

# 12. Generics

Generic structures:

```txt
struct Box[T] {
    value: T
}
```

Usage:

```txt
box: Box[int] = Box[int] {
    value: 10
}
```

---

## Generic Constraints

Interfaces may be used as constraints.

Example:

```txt
interface Comparable[T] {
    compare(other: T): int
}
```

Generic constraint:

```txt
struct SortedList[T: Comparable] {
    values: []T
}
```

---

## Generic Functions

```txt
function first[T](arr: []T): T {
    return arr[0]
}
```

Usage:

```txt
x := first[int]([1,2,3])
```

---

# 13. Collections

## Fixed Arrays

```txt
numbers: [3]int = [3]int {
    1,
    2,
    3
}
```

## Dynamic Arrays

```txt
numbers: []int = []int {
    1,
    2,
    3
}
```

## Dictionaries

```txt
dict: dictionary[str]int = dictionary[str]int {
    "one": 1,
    "two": 2
}
```

## Sets

```txt
set: set[str] = set[str] {
    "a",
    "b",
    "c"
}
```

---

# 14. Enums

Enums define finite sets of values.

Example:

```txt
enum TrafficState {
    Red
    Yellow
    Green
}
```

Usage:

```txt
state: TrafficState = TrafficState.Red
```

Enums are the recommended type for state machines.

---

# 15. Type Inspection

Runtime type inspection:

```txt
typeof(value)
```

Example:

```txt
value: (int | str)

switch typeof(value) {

    case int {
        print("integer")
    }

    case str {
        print("string")
    }
}
```

---

# 16. Control Flow

Conditional:

```txt
if condition {

}
else if condition {

}
else {

}
```

Ternary:

```txt
condition ? a : b
```

Switch:

```txt
switch value {

    case 1 {

    }

    case 2 {

    }

    default {

    }
}
```

---

# 17. Loops

While:

```txt
while condition {

}
```

For-each:

```txt
for value in collection {

}
```

Dictionary iteration:

```txt
for key, value in dict {

}
```

Range iteration:

```txt
for i in 0..10 {

}
```

Upper bound is exclusive.

---

# 18. Errors

Error interface:

```txt
interface error {
    error(): str
}
```

Additional error-handling syntax is implementation-defined.

---

# 19. Concurrency

## Channels

Buffered:

```txt
ch: channel[int] = channel[int](1)
```

Unbuffered:

```txt
ch: channel[int] = channel[int]()
```

Send:

```txt
ch <- 10
```

Receive:

```txt
value := <-ch
```

---

## Tasks

Syntax:

```txt
run function() {
    print("hello")
}()
```

`run` creates a lightweight scheduled task.

The runtime may execute many tasks on a smaller number of operating system threads.

This behavior is similar to goroutines.

Channel operations and `run` are inherently impure — they may not appear inside `pure` functions or contract bodies.

---

# 20. Events

Events are strongly typed.

Declaration:

```txt
event UserCreated {
    id: int
}
```

Emission:

```txt
emit UserCreated {
    id: 10
}
```

Subscription:

```txt
on UserCreated := event {
    print(event.id)
}
```

Events are implemented internally using channels and tasks.

Emitting and subscribing to events are inherently impure — they may not appear inside `pure` functions or contract bodies.

---

# 21. Reactive State

Reactive state allows code to execute when a value changes.

Example:

```txt
counter: int = 0

on state(counter) := value {
    print(value)
}
```

Conditional listeners:

```txt
on state(counter) := value; value == 10 {
    print("counter reached 10")
}
```

The observed variable cannot be modified from inside its own state handler.

Example:

```txt
on state(counter) := value {
    counter = value + 1
}
```

This is a compile-time error.

Reactive state handlers are inherently impure — they may not be marked `pure`, though they may call pure functions internally.

---

# 22. State Machines

State variables:

```txt
current: state[TrafficState]
```

Machine definition:

```txt
machine current {

    state TrafficState.Red

    state TrafficState.Yellow

    state TrafficState.Green

    on TrafficState.Red {
        current -> TrafficState.Green
    }

    on TrafficState.Green {
        current -> TrafficState.Yellow
    }

    on TrafficState.Yellow {
        current -> TrafficState.Red
    }
}
```

Transitions use:

```txt
stateVariable -> NewState
```

---

# 23. Decorators

Decorators transform functions.

Example:

```txt
function log(f: function): function {

    return function() {
        print("before")
        f()
        print("after")
    }
}
```

Usage:

```txt
@log

function hello() {
    print("hello")
}
```

A decorator may itself be `pure` if it does not introduce side effects. A `pure` function may only use a decorator that is itself `pure`.

---

# 24. Macros

Macros are compile-time token templates.

A macro takes tokens as input and produces tokens as output. After all macros
are expanded, the compiler validates the resulting code normally — no different
from hand-written code.

Macros are not runtime features. They have no existence at runtime.

---

## Simple Macro

Syntax:

```txt
macro name(param1, param2, ...) {
    body
}
```

Each parameter captures the tokens passed at the call site.

Example:

```txt
macro say(message) {
    print(message)
}
```

Usage:

```txt
say("hello")    // → print("hello")
say(42)          // → print(42)
say(x + 1)       // → print(x + 1)
```

Parameters are substituted as-is — no evaluation, no type checking. Type
checking and validation happen after expansion.

---

## Block Macro

A block macro accepts one or more brace-delimited blocks as additional
parameters.

Syntax:

```txt
macro name(params...)[blockName] {
    body
}
```

A block parameter captures everything inside `{ }` at the call site as a
single token tree (the braces are not included).

Example:

```txt
macro repeat(n)[body] {
    .for i in 0..n {
        body
    }
}
```

Usage:

```txt
repeat(3) {
    print("hi")
}
```

Expands to:

```txt
print("hi")
print("hi")
print("hi")
```

---

## Substitution

### Bare names

Inside a macro body, a **macro parameter name** appearing as a complete token
is replaced by the captured tokens.

```txt
macro greet(name) {
    print("hello, " + name)
}
```

```txt
greet("world")   // → print("hello, " + "world")
```

### ${name}

`${name}` substitutes the tokens of a parameter or loop variable **in any
position** — including inside larger token sequences where a bare name would
not be recognized.

Example — loop variables (which cannot use bare-name substitution):

```txt
.for i in 0..5 {
    element${i} := list[${i}]
}
```

Expands to:

```txt
element0 := list[0]
element1 := list[1]
element2 := list[2]
element3 := list[3]
element4 := list[4]
```

`${name}` is always valid for any parameter or loop variable.

### Literal ${}

To produce a literal `${name}` without substitution, prefix with a backslash:

```txt
\${name}
```

Output:

```txt
${name}
```

---

## Directives

Directives control macro expansion. They are only recognized inside macro
bodies. All directives start with `.`. They are not valid outside macros.

### .for

Repeat a block of template tokens for each value in a range.

Syntax:

```txt
.for name in start..end {
    body
}
```

- `name` is a loop variable available via `${name}`
- `start` and `end` are integer literals
- Upper bound `end` is exclusive
- `.for` loops may be nested

### .if / .else

Conditionally include template tokens.

```txt
.if condition {
    body
}

.else {
    body
}
```

`condition` supports:

- `<name>` — true if the parameter or loop variable is non-zero or non-empty
- `<name> == <value>` — equality against a literal
- `<name> % <n> == <r>` — modulo (useful with `.for` indices)

`.else` is optional.

Example:

```txt
macro repeatEven(n)[body] {
    .for i in 0..n {
        .if i % 2 == 0 {
            body
        }
    }
}
```

---

## What Macros Cannot Do

- Call functions or execute arbitrary code at compile time
- Perform IO (read files, print to console, network access, etc.)
- Access runtime values, types, or variables
- Define, modify, or inspect anything outside the generated token stream
- Execute `.for` or `.if` outside a macro body
- Use `.for` with non-integer bounds (compile-time error)

Macros only rearrange tokens. Nothing else.

---

## Generated Code

Expanded code is parsed and validated exactly like hand-written code. There
is no special exemption for purity, types, contracts, or any other language
rule. If a macro generates invalid code, the compiler reports an ordinary
compile error.

---

## Operators

Operators are functions with symbolic names that support infix, prefix, and postfix call syntax.

### Declaration

Infix operator (default):

```txt
operator `~=` (a: integer, b: float): boolean {
    return a == integer(b)
}
```

Prefix operator:

```txt
prefix operator `√` (x: float): float {
    return sqrt(x)
}
```

Postfix operator:

```txt
postfix operator `++` (x: *int): int {
    let val = *x
    *x = val + 1
    return val
}
```

### Operator Symbols

Operator symbols consist of one or more characters from:

The following are reserved and cannot be used as operator names:
`.` (member access), `(` `)` (call), `[` `]` (subscript), `,` `;` `:` (punctuation).

### Precedence and Associativity

Built-in operators have fixed precedence levels. Custom operators may declare precedence and associativity:

```txt
operator `+++` (a, b: int): int precedence 6 associativity left {
    return a + b + 1
}
```

Default precedence: 5 (additive). Default associativity: left.

Precedence levels:

| Level | Category | Examples |
|-------|----------|---------|
| 0 | Assignment | `=`, `:=`, `+=` |
| 1 | Logical OR | `\|\|` |
| 2 | Logical AND | `&&` |
| 3 | Comparison | `==`, `!=`, `<`, `>`, `<=`, `>=` |
| 4 | Range | `..` |
| 5 | Additive | `+`, `-` |
| 6 | Multiplicative | `*`, `/`, `%` |
| 7 | Unary (prefix) | `-`, `!`, `&`, `*` |
| 8 | Exponentiation | `^` |
| 9 | Postfix | `++`, `--` |
| 10 | Member access | `.`, `()` |

### Overloading Rules

1. **New symbol** — Always allowed.
2. **Existing symbol, at least one user-defined type** — Allowed.
3. **Existing symbol, all built-in types, same parameter combination** — NOT allowed.
4. **Existing symbol, all built-in types, different combination** — Allowed.
5. **Comparison operators** (`==`, `!=`, `<`, `>`, `<=`, `>=`) must return `boolean`.
6. A symbol cannot be declared as both prefix and infix.
7. An operator may be declared `pure`; it follows the same restrictions as any `pure` function.

Example of overloading `+` for a user type:

```txt
operator `+` (p: Point, v: Vector): Point {
    return Point { x: p.x + v.dx, y: p.y + v.dy }
}
```

### Operators in Interfaces

Operators may appear in interface declarations:

```txt
interface Addable[T] {
    operator `+` (a, b: T): T
}
```

Generic constraint:

```txt
function sum[T: Addable](values: []T): T {
    // `+` is available on T
}
```

### Resolution

Operator resolution follows the same rules as function overloading: exact match preferred, then implicit conversions, ambiguity is a compile-time error. Resolution occurs at compile time.

### Desugaring

An operator call is syntactic sugar for a function call:

```
a `~=` b  →  operator`~=`(a, b)
√x        →  prefix operator`√`(x)
x++       →  postfix operator`++`(x)
```

Operators may also be called using function syntax:

```txt
operator`+`(a, b)
```

### Visibility

Operators follow the same visibility rules as functions. Private by default:

```txt
public operator `+++` (a, b: int): int
```

---

# 25. Design By Contract

The language provides four contract features:

```txt
require
ensure
invariant
can
```

---

## Invariants

Variable invariant:

```txt
x: int = 10

invariant x {
    this > 0
}
```

Type invariant:

```txt
type Natural integer

invariant Natural {
    this >= 0
}
```

Class invariant:

```txt
class Person {

    age: int

    invariant this {
        this.age >= 0
    }
}
```

Struct invariant:

```txt
struct Range {

    start: int
    end: int

    invariant this {
        this.start <= this.end
    }
}
```

---

## Preconditions

```txt
function sqrt(x: float): float {

    require x >= 0

    return implementation()
}
```

---

## Postconditions

```txt
function increment(x: int): int {

    ensure result > x

    return x + 1
}
```

`result` refers to the return value.

---

## Contract Evaluation

Contracts may call functions.

Example:

```txt
require isPrime(x)
```

The compiler attempts to reject obviously non-terminating contract evaluation.

All contract bodies (`require`, `ensure`, `invariant`, and `can`) are **pure contexts**. Only pure functions and implicitly pure expressions are permitted inside contracts. The compiler rejects any impure call inside a contract body.

Side effects are eliminated by the pure context — impure calls are rejected at compile time. However, expensive or non-terminating pure computations inside contracts remain the responsibility of the developer.

---

## can

`can` verifies whether a contract can be satisfied.

Example:

```txt
print(can sqrt(10))
```

Output:

```txt
true
```

Example:

```txt
print(can sqrt(-1))
```

Output:

```txt
false
```

`can` only evaluates:

* invariants
* require conditions
* ensure conditions

It does not execute normal program behavior outside contract evaluation.

---

# 26. Pure Functions

A pure function is a function that has no side effects and whose return value depends only on its arguments.

## Declaration

```txt
pure function square(x: int): int {
    return x * x
}
```

## Guarantees

A `pure` function guarantees:

* No mutation of state outside its local scope
* No IO (print, file, network, etc.)
* No channel operations, task spawning, or event emission
* No interaction with reactive state
* It may only call other `pure` functions
* Its return value depends solely on its arguments (referential transparency)

The compiler enforces these guarantees at compile time. Violations are rejected.

## Implicit Purity

The following are implicitly pure and may appear in any pure context:

* Literals, variable reads, arithmetic, boolean, and comparison operations
* Calls to `pure` functions
* Value type (struct) construction
* `typeof()` — runtime type inspection
* Enum member access and comparison

## Purity and Contracts

Contract bodies (`require`, `ensure`, `invariant`, `can`) are **pure contexts**.

Only pure functions and implicitly pure expressions are permitted inside contracts.

The compiler rejects any impure call inside a contract body.

## Purity and Interfaces

Interface methods may be declared `pure`:

```txt
interface Hashable {
    pure function hash(): int
}
```

Every implementation of a `pure` interface method must also satisfy the purity guarantees.

## Purity and Decorators

A decorator may be `pure` if it introduces no side effects. A `pure` function may only be decorated with a `pure` decorator.

## Default Rule

All functions are impure by default. Only functions explicitly marked `pure`, or implicitly pure expressions, carry purity guarantees.

---

# End of Specification

