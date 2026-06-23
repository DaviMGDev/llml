# Language Specification Draft

## 1. Lexical Elements
### Comments
```
// Single-line comment
/* 
   Multi-line 
   comment 
*/

```
### Primitives
```
// Supported primitive types:
// integer, float, string, character, boolean, void, any, null
// pointer (TBD: depends on compilation/interpretation strategy)

```
## 2. Types and Variables
### Type Aliases and Unions
```
// Derive new types or create aliases
type int integer 

// Define union types
type number (int | float)

```
### Variable Declaration
```
x: int = 10          // Explicit type
y := 0.1             // Type inference

```
## 3. Data Structures
### Arrays
```
dynamic: []int               // Dynamic array (slice)
append(dynamic, 10)
concat(dynamic, [1, 2, 3])

static: [2]int               // Static array (fixed size)
// static[2] = 10            // Panics: out of bounds
// append(static, 10)        // Panics: cannot append to static array

mixed: [](number | string)   // Array of unions
generic: []any               // Array of any type

```
### Dictionaries and Sets
```
dict: dictionary[string]any = {
    "key1": 10,
    "key2": 1.1,
    "key3": null 
}

s: set[any] = {10, 33, 10.0, "hi", "hi", null} 
// Note: "hi" is deduplicated. 10 and 10.0 are kept as distinct due to strict type equality.

```
### Tuples
```
t: (int, string) = (10, "hi") 
// Accessed via index: t[0], t[1]

```
## 4. Functions and Interfaces
### Function Declarations
```
function add(a, b: integer): integer {
    return a + b 
}

// Anonymous functions assigned to variables
sub: function[int, int]int = function(a, b: int): int {
    return a - b 
}

```
### Interfaces
```
// Methods defined in interfaces are implicitly public
type IntInterface interface {
    string(): string
}

```
## 5. Object-Oriented Programming
### Classes
```
class Integer {
    value: int 
    
    function init(value: int) {
       this.value = value 
    }
    
    function string(): string {
       return "${this.value}"
    }
}

```
### Anonymous Classes
```
obj: object = class { 
    data: any = "some data?"
    
    function method(): string {
       return "hi... I guess?"    
    }
}

```
### Generics
```
class GenericClass[T] {
    data: T 
}

// Constrained Generics
type otherExampleI[T: Comparable] interface {} 

```
## 6. Control Flow and Error Handling
### Go-Style Error Handling
```
type error interface {
    error(): string 
}

function invalid(n: int): (any, error) {
    if n <= 0 {
        return null, {
           function error(): string {
                return "Invalid number"
            }
        }
    }
    return n, null 
}

value, err := invalid(-1)
if err != null {
    print(err.error())
} else {
    print(value)
}

```
### Defer
```
function repeat(n: int) {
    defer function() {
        print("function finished")
    }()
    
    for i in 0..n {
        print("${i}")
    }
}

```
## 7. Concurrency and Asynchronous
### Channels and Goroutines
```
chan: channel[int] 

// Goroutine equivalent to Go's `go` keyword
run function(ch: channel[int]) { 
    ch <- 10 
}(chan)

blocking := <-chan
print(blocking) // 10

```
### Async/Await
```
// Standard async/await syntax planned, backed by channels/concurrency primitives.

```
## 8. Metaprogramming (Macros)
### Aliases
```
// Simple text substitution
alias method function  
method thisisalsoafunction() {} // Expands to: function thisisalsoafunction() {}

```
### Parameterized Macros
```
macro func(name) {
    function ${name}()
}
#func(some) {} // Expands to: function some() {}

```
### Macros with Control Flow
```
macro repeat(n)[odd_body, even_body] {
    #for i in 0..n {
       #if ${i} % 2 == 0 {
           ${odd_body}
       } else {
           ${even_body}
       }
    }
}

#repeat(10) {
    print("hi")
}, {
    print("bye")
}
// Note: Macros are preprocessed, not computed at runtime.

```
## 9. Reactive Programming
### Function Interception
```
// Triggered before computation
on repeat(n: int) { 
    print("repeat function called with ${n}")
}

// Triggered after computation (memoized/cached)
on add(a, b: int) == value { 
    print("add resulted in ${value}")
}

// Triggered for specific arguments
on add(1, 2) { 
    print("add called with 1 and 2")
}

```
### Variable Observation
```
var: any 

// Triggered on read/write access
on var { 
    print("var accessed")
    if old(var) == var {
        print("read operation")
    } else {
        print("changed from ${old(var)} -> ${var}")
    }
}

// Triggered only when updated to a specific value
on var == 10 { 
    print("var is now 10")
}

// IMPORTANT: Modifying the observed variable inside the `on` block is strictly forbidden to prevent infinite loops.

```
## 10. Design by Contract (Invariants & Assertions)
### Type Invariants
```
type natural number 
invariant natural this >= 0

type password string {
    len(this) >= 8,
    len(this) <= 20
}

// Constants via Invariants
type euler float 
invariant euler {
    this == 2.71
}

```
### Runtime Invariant Checking
```
// The `can` keyword checks invariants at runtime (does not check types)
e: euler = 2.71 
print(can e = 2.71) // true 
print(can e = 2.7)  // false 

```
### Function Contracts (Require / Ensure)
```
function simplefn(arg: number, arg2: []int): int {
    require {
        len(arg2) >= 2 
        arg > 0 
    }
    ensure {
        result > 0 
    }
    return sum(arg2) + int(arg)
}

```
### Interface and Class Contracts
```
type exampleI interface {
    method(a, b: number): number {
        require { a > 10 }
        ensure { result < 10 }
    }
}

class Example {
    ensure {
        that implements exampleI
    }
    
    value: natural {
        this.value > 18 // Internal attribute invariant
    }
    
    function init(value: natural) {
        this.value = value
    }
}

```
## 11. Modules and Packages
```
package main 

import (
    "modulename"
)
```
