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
adder: function[integer, integer] integer
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

---

# 24. Macros

Macros execute during compilation.

Macros generate source code.

Macros are not runtime features.

---

## Simple Macro

```txt
macro say(message) {
    print(message)
}
```

Usage:

```txt
say("hello")
```

---

## Block Macro

```txt
macro repeat(n)[code] {

    .for i in 0..n {

        .if i % 2 == 0 {

            code
        }
    }
}
```

Usage:

```txt
repeat(10) {
    print("hello")
}
```

---

## Macro Substitution

Macro variables are expanded using:

```txt
${name}
```

Example:

```txt
.for i in 0..10 {
    ${i}
}
```

Expansion:

```txt
0
1
2
...
```

Literal output:

```txt
\${i}
```

Expansion:

```txt
${i}
```

Macros are not required to generate valid code.

Validation occurs after macro expansion.

--- 

## Macro new operators:

```
macro `op`(a, b) {
    a + b 
}

// whenever we type:
//<something> op <otherthing> it will be actually <something> + <otherthing>
// since it is basically text replacement, this is valid:
macro `~=`(x, y) {
    x == y // an example 
}

// with interfaces:
interface Comparable[T] {
    equals(other: T): boolean 
}
macro `==`(a, b) {

}
// nop, gonna need a better system for custom operators 
operator[op](a, b: type) {
} 

operator[~=](a: integer, b: float): boolean {
    return a == integer(b)
}

// operator[<existent operator>](a, b: <primitive types>): <type> {
    // this is not alowed!!!!
// }
/*
if you are using a existent operator:
    if types are equals:
        not allowed 
    else:
        allowed 
else:
    allowed 

conditional operators must return boolean always
custom operators can return custom types 
operator[·](void, b: type): type {
    return *b  
}

x: ·integer = &(integer(10))
*/

print(10 ~= 10.1) // true, I guess?
// ?
// okay, I really need to think more about how I would implement that.
// THIS IS NOT OPTIONAL FEATURE. IT IS A MUST!
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

Preventing side effects and expensive computations inside contracts is the responsibility of the developer.

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

# End of Specification

